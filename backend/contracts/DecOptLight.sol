// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import "./Dates.sol";
import "./compound/CTokenInterfaces.sol";

struct Stock {
    uint stockID;
    string stockName;
    uint price;
    uint priceLastUpdated;
    string priceSource;
    string pricePath;
}

struct OptionCreationData {
    uint stockID;
    uint _strikePrice;
    uint _price;
    bool _isCall;
    address creator;
}

struct Option {

    uint optionID;
    uint stockID;
    address creator;
    address owner;
    
    uint strikePrice;
    uint expirationTimestamp;
    uint price;
    uint collateral;

    bool isCall;
    bool isInTheMarket;
    bool isExercised;
}

struct User {
    uint userID;  // Is this necessary?
    address userAddress;
    uint[] createdOptions;
    uint[] ownedOptions;
}


contract DecOpt is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    event OptionCreated(
        bytes32 chainlinkRequestID,
        bool success
    );

    IERC20 private usdcToken;
    CErc20Interface private cUsdcToken;
    BokkyPooBahsDateTimeLibraryEdited private DatesLibrary = new BokkyPooBahsDateTimeLibraryEdited();
    uint256 private chainLinkFee;
    mapping(bytes32 => uint256) private chainLinkRequestIDToOptionID;
    mapping(bytes32 => OptionCreationData) private chainLinkRequestIDToOptionCreationData;
    
    uint256 public OPTION_LIFETIME = 2592000;  // 1 MONTH IN SECONDS
    uint8 public BATCH_SIZE = 10;

    Stock[] public stocks;

    mapping(address => User) public users;
    uint256 public userCount;
  
    Option[] public options;
    uint public listedOptionsCount = 0;
    
    uint usdcDecimalsMultiplicator = 10**18;

    /*
        GOERLI:
            usdc 0x07865c6e87b9f70255377e024ace6630c1eaa37f
            cusdc 0x3EE77595A8459e93C2888b13aDB354017B198188
            linkToken 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
            oracle 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7
            jobid ca98366cc7314957b8c012c72f05aeeb
            0x07865c6e87b9f70255377e024ace6630c1eaa37f,0x3EE77595A8459e93C2888b13aDB354017B198188,0x326C977E6efc84E512bB9C30f76E30c160eD06FB,0xCC79157eb46F5624204f47AB42b3906cAA40eaB7,ca98366cc7314957b8c012c72f05aeeb
    */
    constructor(address _usdcToken, address _cUsdcToken, address _linkToken, address _oracle) ConfirmedOwner(msg.sender) {
        setChainlinkToken(_linkToken);
        setChainlinkOracle(_oracle);
        usdcToken = IERC20(_usdcToken);
        cUsdcToken = CErc20Interface(_cUsdcToken);
        chainLinkFee = 10**17; // 0,1 * 10**18 (Varies by network and job)
    }

    function removeByValue(uint[] storage array, uint value) internal {
        uint index;
        for (index = 0; index < array.length; index++){
            if (array[index] == value) {
                break;
            }
        }

        for (uint i = index; i < array.length-1; i++){
            array[i] = array[i+1];
        }

        if (index < array.length) {
            array.pop();
        }
    }

    function getStocks() public view returns (Stock[] memory) {
        return stocks;
    }

    function getOptions() public view returns (Option[] memory) {
        return options;
    }

    function getListedOptions() public view returns (Option[] memory) {
        Option[] memory listedOptions = new Option[](listedOptionsCount);
        uint listedOptionsindex = 0;
        for (uint i = 0; i < options.length; i++) {
            if (options[i].isInTheMarket) {
                listedOptions[listedOptionsindex++] = options[i];
            }
        }
        return listedOptions;
    }

    function getCreatedOptions() public view returns (Option[] memory) {
        User storage user = users[msg.sender];
        Option[] memory createdOptions = new Option[](user.createdOptions.length);
        for (uint i = 0; i < user.createdOptions.length; i++) {
            createdOptions[i] = options[user.createdOptions[i]];
        }
        return createdOptions;
    }

    function getOwnedOptions() public view returns (Option[] memory) {
        User storage user = users[msg.sender];
        Option[] memory ownedOptions = new Option[](user.ownedOptions.length);
        for (uint i = 0; i < user.ownedOptions.length; i++) {
            ownedOptions[i] = options[user.ownedOptions[i]];
        }
        return ownedOptions;
    }

    function addStock(string calldata stockName, string calldata priceSource, string calldata pricePath) public onlyOwner {
        uint stockID = stocks.length;
        stocks.push(Stock(
            stockID,
            stockName,
            0,
            block.timestamp,
            priceSource,
            pricePath
        ));
    }

    function createUser(address _address) public {
        require(users[_address].userAddress == address(0x0), "This user already exists");
        User memory newUser = User(userCount, _address, new uint[](0), new uint[](0));
        users[_address] = newUser;
        userCount += 1;
    }

    function getUserFromAddress(address _address) internal returns (User storage) {
        if (users[_address].userAddress == address(0x0)) {
            createUser(_address);
        }
        return users[_address];
    }

    function createOption(uint stockID, uint _strikePrice, uint _price, bool _isCall) public returns (bytes32) {
        require(stockID < stocks.length, "This stockID does not exist");
        Stock storage stock = stocks[stockID];
        User storage user = getUserFromAddress(msg.sender);
        Chainlink.Request memory req = buildChainlinkRequest(
            "ca98366cc7314957b8c012c72f05aeeb",
            address(this),
            this.fullfilCreateOption.selector
        );
        req.add("get", stock.priceSource);
        req.add("path", stock.pricePath);
        req.addInt("times", int(usdcDecimalsMultiplicator));
        bytes32 _requestId = sendChainlinkRequest(req, chainLinkFee);
        chainLinkRequestIDToOptionCreationData[_requestId] = OptionCreationData(
            stockID,
            _strikePrice,
            _price,
            _isCall,
            user.userAddress
        );
        return _requestId;
    }
    
    function fullfilCreateOption(bytes32 _requestId, uint256 _priceData) public recordChainlinkFulfillment(_requestId) {
        OptionCreationData storage data = chainLinkRequestIDToOptionCreationData[_requestId];
        Stock storage stock = stocks[data.stockID];
        User storage user = getUserFromAddress(data.creator);
        uint collateral = (_priceData * usdcDecimalsMultiplicator * BATCH_SIZE * 3)/2;
        
        if (usdcToken.balanceOf(user.userAddress) < collateral || usdcToken.allowance(user.userAddress, address(this)) < collateral) {
            emit OptionCreated(_requestId, false);
            return;
        }
        usdcToken.transferFrom(user.userAddress, address(this), collateral);
        usdcToken.approve(address(cUsdcToken), collateral);
        require(cUsdcToken.mint(collateral) == 0, "Compounding failed");

        uint expirationTimestamp = block.timestamp + OPTION_LIFETIME;
        

        uint optionID = options.length;
        Option memory newOption = Option(optionID, stock.stockID, user.userAddress, user.userAddress, data._strikePrice, expirationTimestamp, data._price, collateral, data._isCall, true, false);

        user.createdOptions.push(optionID);
        user.ownedOptions.push(optionID);
        options.push(newOption);
        listedOptionsCount += 1;

        emit OptionCreated(_requestId, true);
    }



    function buyOption(uint _optionID) public payable {
        Option storage option = options[_optionID];
        User storage user = getUserFromAddress(msg.sender);
        User storage optionOwner = getUserFromAddress(option.owner);
        require(option.isInTheMarket == true);
        require(option.isExercised == false);
        require(option.owner != user.userAddress, "You already own this option");

        uint batchPrice=usdcDecimalsMultiplicator*option.price*10;  //Check this
        require(usdcToken.balanceOf(user.userAddress) >= batchPrice, "Insufficient USDC balance");
        require(usdcToken.allowance(user.userAddress, address(this)) >= batchPrice, "Approval not given");

        usdcToken.transferFrom(user.userAddress, optionOwner.userAddress, batchPrice);
        removeByValue(optionOwner.ownedOptions, option.optionID);

        option.owner = user.userAddress;
        option.isInTheMarket = false;

        user.ownedOptions.push(option.optionID);
        listedOptionsCount -= 1;
    }

    function exerciseOption(uint _optionID) public returns (bytes32) {
        Option storage option = options[_optionID];
        Stock storage stock = stocks[option.stockID];
        User storage user = getUserFromAddress(msg.sender);
        User storage optionCreator = getUserFromAddress(option.creator);

        require(option.owner == user.userAddress, "You are not the owner of this option");
        require(option.isExercised == false, "This option is already exercised");
        require(block.timestamp <= option.expirationTimestamp, "This option is expired");  //revisar estoo
        option.isExercised = true;  // Prevents reentrancy

        removeByValue(user.ownedOptions, option.optionID);
        removeByValue(optionCreator.createdOptions, option.optionID);

        // Recuperamos la guita del pool de compound y actualizamos option.collateral
        cUsdcToken.redeemUnderlying(option.collateral);

        Chainlink.Request memory req = buildChainlinkRequest(
            "ca98366cc7314957b8c012c72f05aeeb",
            address(this),
            this.fulfillExerciseOption.selector
        );
        req.add("get", stock.priceSource);
        req.add("path", stock.pricePath);
        req.addInt("times", int(usdcDecimalsMultiplicator));
        bytes32 _requestId = sendChainlinkRequest(req, chainLinkFee);
        chainLinkRequestIDToOptionID[_requestId] = option.optionID;
        return _requestId;
    }

    function fulfillExerciseOption(bytes32 _requestId, uint256 _priceData) public recordChainlinkFulfillment(_requestId) {
        // update stock price
        Option storage option = options[chainLinkRequestIDToOptionID[_requestId]];
        User storage user = getUserFromAddress(option.owner);
        Stock storage stock = stocks[option.stockID];
        stock.price = _priceData;
        stock.priceLastUpdated = block.timestamp;

        uint256 gain;
        if (option.isCall) {
            gain = option.strikePrice > _priceData ? 0 : (option.strikePrice-_priceData)*BATCH_SIZE;
        } else {
            gain = option.strikePrice < _priceData ? 0 : (_priceData-option.strikePrice)*BATCH_SIZE;
        }

        if (option.collateral > gain) {
            usdcToken.transfer(user.userAddress, gain);
            usdcToken.transfer(option.creator, option.collateral-gain);
        } else {
            usdcToken.transfer(option.creator, option.collateral);
        }

        if (option.isInTheMarket) {
            option.isInTheMarket = false;
            listedOptionsCount -= 1;
        }
    }}
