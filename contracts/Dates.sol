// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

contract BokkyPooBahsDateTimeLibraryEdited {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    // ------------------------------------------------------------------------
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }
    

    function MonthToString(uint _month) public  pure returns(string memory month) {
         string[12] memory months = [
            "ENE",
            "FEB",
            "MAR",
            "ABR",
            "MAY",
            "JUN",
            "JUL",
            "AGO",
            "SEP",
            "OCT",
            "NOV",
            "DIC"
        ];
        require (_month>0,"Month 0 is not a month");
        month=months[_month-1];
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        uint256 twok=2000;
        uint256 rawyear;
        (rawyear, month,  day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        if (rawyear>twok){
            year=rawyear-twok;
        }
        else
        year=rawyear;
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }
        function timestampToDateView(uint timestamp) public pure returns (uint year, uint month, uint day) {
        (year, month, day) = timestampToDate(timestamp);
    }
    function timestampToDateTimeView(uint timestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day, hour, minute, second) = timestampToDateTime(timestamp);
    }
    function time()  public view returns(uint){
        uint timez= block.timestamp;
        return timez;
    }

function uintToString(uint256 num) internal pure returns (string memory) {
        if (num == 0) {
            return "0";
        }
        
        uint256 tempNum = num;
        uint256 length;

        while (tempNum > 0) {
            length++;
            tempNum /= 10;
        }

        bytes memory buffer = new bytes(length);

        while (num > 0) {
            length--;
            buffer[length] = bytes1(uint8(48 + num % 10));
            num /= 10;
        }

        return string(buffer);
    }



    function OptionFormat( string memory _ticker,uint _expiration,bool _isCall) public view returns(string memory){
        (uint year,uint month, uint day)=timestampToDate(_expiration);
        string memory VorC = _isCall ? "C" : "V";
        bytes memory result = bytes(string(abi.encodePacked(_ticker,VorC,uintToString(day),MonthToString(month), uintToString(year))));
        
        return string(result);
    }


}

