// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@compound-finance/compound-protocol/contracts/CTokenInterfaces.sol";

import "./Dates.sol" ;

//SON LOTES DE 10 ACCIONES


//TODO
//Manejar timestamp y ejercicio
//TODO: Crear ticker, ejemplo GGALC271023
//Tenes todo en remix
 

contract DecOpt is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    struct Stock {
        uint stockID;
        string stockName;
        uint price;
        uint priceLastUpdated;
        string priceSource;
        string pricePath;
    }

    struct Option {
        string ticker;  //Whats this for?

        uint optionID;
        uint stockID;
        address creator;
        address owner;
        
        uint strikePrice;
        uint expiration;
        uint price;
        uint compoundTokens;
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

    event OptionCreated(
        address indexed Lanzador,
        uint strikePrice,
        uint expiration,
        uint price,
        uint collateral,
        bool isCall
    );

    IERC20 private usdtToken;
    CErc20Interface private cUsdtToken;
    BokkyPooBahsDateTimeLibraryEdited private DatesLibrary = new BokkyPooBahsDateTimeLibraryEdited();
    bytes32 private chainLinkJobId;
    uint256 private chainLinkFee;
    mapping(bytes32 => uint256) private chainLinkRequestIDToOptionID;
    
    uint256 public OPTION_LIFETIME = 2592000;  // 1 MONTH IN SECONDS

    Stock[] public stocks;

    mapping(address => User) public users;
    uint256 public userCount;
  
    Option[] public options;
    uint public listedOptionsCount = 0;
    uint public mervalIndex = 783; //Se remplaza por CHAINLINK
    
    uint usdtvalue = 10**18;

    constructor(address _usdtToken, address _cUsdtToken, address _linkToken, address _oracle) ConfirmedOwner(msg.sender) {
        setChainlinkToken(_linkToken);
        setChainlinkOracle(_oracle);
        usdtToken = IERC20(_usdtToken);
        cUsdtToken = CErc20Interface(_cUsdtToken);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
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
            if (options[i].isInTheMArket) {
                listedOptions[listedOptionsindex++] = options[i];
            }
        }
        return listedOptions;
    }

    function getCreatedOptions() public view returns (Option[] memory) {
        User storage user = users[msg.sender];
        Option[] memory createdOptions = new Option[](user.createdOptions.length);
        for (uint i = 0; user.createdOptions.length; i++) {
            createdOptions[i] = options[user.createdOptions[i]];
        }
        return createdOptions;
    }

    function getOwnedOptions() public view returns (Option[] memory) {
        User storage user = users[msg.sender];
        Option[] memory ownedOptions = new Option[](user.ownedOptions.length);
        for (uint i = 0; user.ownedOptions.length; i++) {
            ownedOptions[i] = options[user.ownedOptions[i]];
        }
        return ownedOptions;
    }

    function addStock(uint stockID, string stockName, string priceSource, string pricePath) public onlyOwner {
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

    function createOption(uint stockID, uint _strikePrice, uint _price, bool _isCall) public {
        require(stockID < stocks.length, "This stockID does not exist");

        User storage user = getUserFromAddress(msg.sender);
        uint collateral = ((mervalIndex * 30)/2) * usdtvalue;  // Check this

        require(usdtToken.balanceOf(user.userAddress) >= collateral, "Insufficient USDT balance, you must collateralize 150%");
        require(usdtToken.allowance(user.userAddress, address(this)) >= collateral, "Approval not given, you must collateralize 150%");
        usdtToken.transferFrom(user.userAddress, address(this), collateral); // priceInUSDT); what is this?
        usdtToken.approve(address(cUsdtToken), collateral);
        uint previousCompoundBalance = cUsdtToken.balanceOf(address(this));
        require(cUsdtToken.mint(collateral) == 0, "Compounding failed");
        uint compundTokens = cUsdtToken.balanceOf(address(this)) - previousCompoundBalance;

        uint expirationTimestamp = block.timestamp + OPTION_LIFETIME;
        
        string memory ticker = DatesLibrary.OptionFormat("MERV", expiration, true);  //check this

        uint optionID = options.length;
        Option memory newOption = Option(ticker, optionID, stockID, user.userAddress, user.userAddress, _strikePrice, expirationTimestamp, _price, compoundTokens, collateral, _isCall, true, false);

        user.createdOptions.push(optionID);
        user.ownedOptions.push(optionID);
        options.push(newOption);
        listedOptionsCount += 1;

        emit OptionCreated(user.userAddress, _strikePrice, expiration, _price, collateral, _isCall);
        //SEND TO COMPUND
    }

    function sellOption(uint _optionID) public {
        Option storage option = options[_optionID];
        require(option.owner == msg.sender, "You are not the owner of this option");
        require(option.isInTheMarket == false, "This option is already in the market");

        option.isInTheMarket = true;
        listedOptionsCount += 1;
    }

    function canceSellOrder(uint256 _optionID) public {
        Option storage option = options[_optionID];
        require(option.owner == msg.sender, "You are not the owner of this option");
        require(option.isInTheMarket == true, "This option is not in the market");
        require(option.isExercised == false, "This option is already exercised");

        option.isInTheMarket = false;
        listedOptionsCount -= 1;
    }

    function buyOption(uint _optionID) public payable {
        Option storage option = options[_optionID];
        User storage user = getUserFromAddress(msg.sender);
        User storage optionOwner = getUserFromAddress(option.owner);
        require(option.isInTheMarket == true, "This option is not in the market");
        require(option.isExercised == false, "This option is already exercised");
        require(option.owner != user.userAddress, "You already own this option");

        uint batchPrice=usdtvalue*option.price*10;  //Check this
        require(usdtToken.balanceOf(user.userAddress) >= batchPrice, "Insufficient USDT balance");
        require(usdtToken.allowance(user.userAddress, address(this)) >= batchPrice, "Approval not given");

        usdtToken.transferFrom(user.userAddress, optionOwner.userAddress, batchPrice);
        removeByValue(optionOwner.ownedOptions, option.optionID);

        option.owner = user.userAddress;
        option.isInTheMarket = false;

        user.ownedOptions.push(option.optionID);
        listedOptionsCount -= 1;
    }

    function exerciseOption(uint _optionID) public {
        Option storage option = options[_optionID];
        Stock storage stock = stocks[option.stockID];
        User storage user = getUserFromAddress(msg.sender);
        User storage optionCreator = getUserFromAddress(option.creator);

        require(option.owner == user.userAddress, "You are not the owner of this option");
        require(option.isExercised == false, "This option is already exercised");
        require(block.timestamp <= option.expiration, "This option is expired");  //revisar estoo
        option.isExercised = true;  // Prevents reentrancy

        removeByValue(user.ownedOptions, option.optionID);
        removeByValue(optionCreator.createdOptions, option.optionID);

        // Recuperamos la guita del pool de compound y actualizamos option.collateral
        uint previuosUsdtBalance = usdtToken.balanceOf(address(this));
        cUsdtToken.redeem(option.compoundTokens);
        option.collateral = usdtToken.balanceOf(address(this)) - previousUsdtBalance;

        Chainlink.Request memory req = buildChainlinkRequest(
            chainLinkJobId,
            address(this),
            this.fulfillExerciseOption.selector
        );
        req.add("get", stock.priceSource);
        req.add("path", stock.pricePath);
        req.addInt("times", 10 ** 18);
        chainLinkRequestIDToOptionID[sendChainlinkRequest(req, fee)] = option.optionID;
    }

    function fulfillExerciseOption(bytes32 _requestId, uint256 _priceData) public recordChainlinkFulfillment(_requestId) {
        // update stock price
        Option storage option = options[chainLinkRequestIDToOptionID[_requestId]];
        User storage user = getUserFromAddress(option.owner);
        Stock storage stock = stocks[option.stockID];
        stock.price = _priceData;
        stock.priceLastUpdated = block.timestamp;

        // check this
        uint256 gain;
        if (option.isCall) {
            gain = option.strikePrice > mervalIndex ? (option.strikePrice-mervalIndex)*10 : 0;     
        } else {
            gain = option.strikePrice < mervalIndex ? (mervalIndex-option.strikePrice)*10 :0;
        }
        //----------

        if (option.collateral > gain) {
            usdtToken.transfer(user.userAddress, gain);
            usdtToken.transfer(optionCreator.userAddress, option.collateral-gain);
        } else {
            usdtToken.transfer(optionCreator.userAddress, option.collateral);
        }

        if (option.isInTheMarket) {
            option.isInTheMarket = false;
            listedOptionsCount -= 1;
        }
    }
}