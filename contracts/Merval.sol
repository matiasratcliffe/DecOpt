// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
 import "hardhat/console.sol";

 //SON LOTES DE 10 ACCIONES


 //TODO
//Manejar timestamp y ejercicio
 //TODO: Crear ticker, ejemplo GGALC271023
 //Tenes todo en remix
 

contract Merval {


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
    uint public mervalIndex=783;
    

    event OptionCreated(
        address indexed Lanzador,
        uint strikePrice,
        uint expiration,
        uint price,
        uint collateral,
        bool isCall
    );

        function createUser(address _address)public {
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
        function createOption(uint _strikePrice, uint _price, bool _isCall) public payable {
        ensureUserExists(msg.sender);

        require(msg.value >= (mervalIndex * 30)/2, "You must collateralize 150% of the price");
        //
        uint expiration=timeStampManager();
        
        string memory ticker="GGALC271023";

        Option memory newOption = Option(ticker,options.length,msg.sender, msg.sender, _strikePrice, expiration, _price, msg.value, _isCall, true, false);


        users[msg.sender].Writtenoptions.push(options.length);
        users[msg.sender].ownedOptions.push(options.length);
        options.push(newOption);

        emit OptionCreated(msg.sender, _strikePrice, expiration, _price, msg.value, _isCall);
    }
    function buyOption(uint _optionID) public payable {
        ensureUserExists(msg.sender);

        require(msg.value >= options[_optionID].price*10, "You must pay the price of the option");
        require(options[_optionID].isInTheMarket == true, "This option is not in the market");
        require(options[_optionID].isExercised == false, "This option is already exercised");
        require(options[_optionID].writer != msg.sender, "You are the writer of this option");
        address writer = options[_optionID].writer;


        payable(writer).transfer(msg.value);

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



    function exerciseOption(uint _optionID) public {
        ensureUserExists(msg.sender);
        require(options[_optionID].owner == msg.sender, "You are not the owner of this option");
        require(options[_optionID].isExercised == false, "This option is already exercised");
        require(block.timestamp <= options[_optionID].expiration, "This option is  expired ");
        options[_optionID].isExercised = true;

        if (options[_optionID].isCall == true) {
            address Writer = options[_optionID].writer;
            uint256 callGain = options[_optionID].strikePrice > mervalIndex ? (options[_optionID].strikePrice-mervalIndex)*10 : 0;     
            if(options[_optionID].collateral>callGain){
            payable(msg.sender).transfer(callGain);
            payable(Writer).transfer(options[_optionID].collateral-callGain);}
            else{
                payable(msg.sender).transfer(options[_optionID].collateral);
            }

        } else {
            uint256 putGain = options[_optionID].strikePrice < mervalIndex ? (mervalIndex-options[_optionID].strikePrice)*10 :0;
            address Writer = options[_optionID].writer;

            if(options[_optionID].collateral>putGain){
            payable(msg.sender).transfer(putGain);
            payable(Writer).transfer(options[_optionID].collateral-putGain);}
            else{
                payable(msg.sender).transfer(options[_optionID].collateral);
            }
            
        }}}
