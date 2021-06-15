// SPDX-License-Identifier: MIT
pragma solidity <=0.8.5;

import "./Token.sol";

contract Presale is Token{
    
    event Bought(uint256 amount);
    uint price = 10; // in wei (its normally for ETH wei so it will be bnb's "wei" (dunno how is that shit called))
    address public idoAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; // to test;
    uint public totalPresale = 100000000;
    uint public percents = 0;

    function lock(uint time_to_lock, uint amount_to_lock) public returns(bool){
        lockedAmount[msg.sender].value += amount_to_lock;
        lockedAmount[msg.sender].time_locked = block.timestamp + time_to_lock * 1 hours;
        return true;
    }

    function buy() payable public {
        uint256 amountToBuy = msg.value * price;
        require(amountToBuy <= balances[idoAddress], "Not enough tokens in the reserve");
        balances[idoAddress] -= amountToBuy;
        balances[msg.sender] += amountToBuy;
        if (percents <= 33){
            lock(12, amountToBuy);
        }
        else if (percents > 33 && percents <= 66){
            lock(24, amountToBuy);
        }
        else{
            lock(36, amountToBuy);
        }
        percents += uint256((amountToBuy * 100) / totalPresale);
        emit Bought(amountToBuy);
    }

}