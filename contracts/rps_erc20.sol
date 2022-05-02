// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ierc20.sol";
import "./viewRPS.sol";

/// @title Transfer functions for - Rock, Paper, Scissors
contract RPS_ERC20 is ViewRPS, IERC20 {

    mapping(address => mapping(address => uint)) public override allowance;

    function transferBalance(address recipient, uint amount) external override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function balance(address owner) external override view returns (uint){
        return balanceOf[owner];
    }

    function approve(address spender, uint amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    /// @notice Adds tokens to sender
    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
        emit Transfer(address(0), msg.sender, msg.value);
    }

    /// @notice Removes tokens from sender and sends them to wallet
    /// @param amount how much wants sender to take out
    function mintOut(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        payable(msg.sender).transfer(amount);
        emit Transfer(msg.sender, address(0), amount);
    }
}