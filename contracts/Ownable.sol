// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Ownable {
  modifier onlyOwner() {
    require(isOwner(), "Function accessible only by the owner");
    _;
  }
  address private _owner;
  constructor() { _owner = msg.sender; }
  function owner() public view returns(address) { return _owner; }  
  function isOwner() public view returns(bool) { return msg.sender == _owner; }
}