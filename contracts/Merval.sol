// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Dates.sol" ;
 //SON LOTES DE 10 ACCIONES


 //TODO
//Manejar timestamp y ejercicio
 //TODO: Crear ticker, ejemplo GGALC271023
 //Tenes todo en remix
 

contract Merval {
    IERC20 public usdtToken;
    function removeByIndex(uint[] storage array, uint index) internal {
        if (index >= array.length) return;

        for (uint i = index; i < array.length-1; i++){
            array[i] = array[i+1];
        }
        array.pop();
    }
    BokkyPooBahsDateTimeLibraryEdited DatesLibrary= new BokkyPooBahsDateTimeLibraryEdited();

    uint timestamp;
    function timeStampManager() public returns (uint)  {
        uint _timestamp=block.timestamp;
        if(_timestamp>timestamp+2592000){
            timestamp=_timestamp+2592000;
        }
        return timestamp;
    }


    struct Option {
        string tikcer;
        uint optionID;
        address writer;
        address owner;
        uint strikePrice;
        uint expiration;
        uint price;
        uint collateral;
        bool isCall;
        bool isInTheMarket;
        bool isExercised;
        
    }
    struct User {
        uint userID;
        address userAddress;
        uint[] Writtenoptions;
        uint[] ownedOptions;
    }

    mapping(address => User) public users;
    uint256 public userCount;
  
    Option[] public options;
    uint public mervalIndex=783; //Se remplaza por CHAINLINK
    
    uint usdtvalue = 10**18;

    event OptionCreated(
        address indexed Lanzador,
        uint strikePrice,
        uint expiration,
        uint price,
        uint collateral,
        bool isCall
    );

        function createUser(address _address)p ublic {
        User memory newUser = User(userCount, _address, new uint[](0), new uint[](0));
        users[_address] = newUser;
        userCount+=userCount;

        }
        function ensureUserExists(address _address) internal {
        if (users[_address].userAddress == address(0)) {
            createUser(_address);
        }
    }
        function getUserData(address _userID) public view returns (User memory) {
        return( users[_userID]);

        }
        function createOption(uint _strikePrice, uint _price, bool _isCall) public  {
        ensureUserExists(msg.sender);
        uint collateral=((mervalIndex * 30)/2)*usdtvalue;

        require(usdtToken.balanceOf(msg.sender) >= collateral, "Insufficient USDT balance,You must collateralize 150%");
        require(usdtToken.allowance(msg.sender, address(this)) >= collateral, "Approval not given,You must collateralize 150% ");
        usdtToken.transferFrom(msg.sender, owner, priceInUSDT);

        uint expiration=timeStampManager();
        
        string memory ticker=DatesLibrary.OptionFormat("MERV",expiration,true);

        Option memory newOption = Option(ticker,options.length,msg.sender, msg.sender, _strikePrice, expiration, _price, collateral, _isCall, true, false);


        users[msg.sender].Writtenoptions.push(options.length);
        users[msg.sender].ownedOptions.push(options.length);
        options.push(newOption);

        emit OptionCreated(msg.sender, _strikePrice, expiration, _price, collateral, _isCall);
        //SEND TO COMPUND
    }
    function buyOption(uint _optionID) public payable {
        ensureUserExists(msg.sender);
        uint batchPrice=usdtvalue*options[_optionID].price*10;
        require(usdtToken.balanceOf(msg.sender) >= batchPrice, "Insufficient USDT balance");
        require(usdtToken.allowance(msg.sender, address(this)) >= batchPrice, "Approval not given");
        require(options[_optionID].isInTheMarket == true, "This option is not in the market");
        require(options[_optionID].isExercised == false, "This option is already exercised");
        require(options[_optionID].writer != msg.sender, "You are the writer of this option");
        address writer = options[_optionID].writer;


        usdtToken.transferFrom(msg.sender, writer, batchPrice);
        removeByIndex(users[writer].ownedOptions, _optionID);

        options[_optionID].owner = msg.sender;
        options[_optionID].isInTheMarket = false;
        
        

        users[msg.sender].ownedOptions.push(_optionID);
    }
    function sellOption(uint _optionID) public {
        ensureUserExists(msg.sender);

        require(options[_optionID].owner == msg.sender, "You are not the owner of this option");
        require(options[_optionID].isInTheMarket == false, "This option is already in the market");
        options[_optionID].isInTheMarket = true;
            }


    function canceSellOrder(uint256 _optionID) public{
        require(options[_optionID].writer == msg.sender, "You are not the writer of this option");
        require(options[_optionID].isInTheMarket == true, "This option is not in the market");
        require(options[_optionID].isExercised == false, "This option is already exercised");
        options[_optionID].isInTheMarket = false;
    }

    function exerciseOption(uint _optionID) public {
        ensureUserExists(msg.sender);
        require(options[_optionID].owner == msg.sender, "You are not the owner of this option");
        require(options[_optionID].isExercised == false, "This option is already exercised");
        require(block.timestamp <= options[_optionID].expiration, "This option is  expired ");
        options[_optionID].isExercised = true;
        removeByIndex(users[msg.sender].ownedOptions, _optionID);
        removeByIndex(users[options[_optionID].writer].Writtenoptions, _optionID);

        if (options[_optionID].isCall == true) {
            address Writer = options[_optionID].writer;
            uint256 callGain = options[_optionID].strikePrice > mervalIndex ? (options[_optionID].strikePrice-mervalIndex)*10 : 0;     
            if(options[_optionID].collateral>callGain){
            //payable(msg.sender).transfer(callGain);-
            //Recuperamos la guita del pool de compound  y  lo mandamos a ambos miembros
            usdtToken.transfer(msg.sender, callGain);
            usdtToken.transfer(Writer, options[_optionID].collateral-callGain);
            }
            else{
                payable(msg.sender).transfer(options[_optionID].collateral);
                usdtToken.transfer(Writer, options[_optionID].collateral);
            }

        } else {
            uint256 putGain = options[_optionID].strikePrice < mervalIndex ? (mervalIndex-options[_optionID].strikePrice)*10 :0;
            address Writer = options[_optionID].writer;

            if(options[_optionID].collateral>putGain){
            payable(msg.sender).transfer(putGain);
            usdtToken.transfer(msg.sender, putGain);
            usdtToken.transfer(Writer, options[_optionID].collateral-putGain);

            }
            else{
            usdtToken.transfer(Writer, options[_optionID].collateral);
            }
            
        }}}