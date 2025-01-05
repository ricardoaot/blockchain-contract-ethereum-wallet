// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EtherWallet {
    // Owner's address
    address public owner;
    bool private locked;

    // Event to register deposits
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
        locked = false;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this operation");
        _;
    }
    
    // Modifier to avoid Reentrancy attempts
    modifier noReentrancy() {
        require(!locked, "Operation in progress, reentry detected");
        locked = true;
        _;
        locked = false;
    }

    // Fallback to receive Ether and record deposit event
    receive() external payable  {
        emit Deposit(msg.sender, msg.value);
    }
    
    // Ether withdrawal function (owner only)
    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient funds");
        payable(owner).transfer(amount);
        emit Withdrawal(owner, amount);
    }

    // Function to transfer Ether to another address (owner only)
    function transfer(address to, uint256 amount) external onlyOwner noReentrancy {
        require(to != address(0), "Address cannot be zero");
        require(amount <= address(this).balance, "Insufficient funds");
        payable(to).transfer(amount);
        emit Transfer(owner, to, amount);
    }
    
    // Function to check the balance of the contract 
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}