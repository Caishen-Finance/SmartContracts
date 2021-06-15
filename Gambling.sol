// SPDX-License-Identifier: MIT
pragma solidity <=0.8.5;

import "./Token.sol";

contract Gambling is Token {

    event Deposited (uint amount);
    event Withdrawn (address indexed to, uint amount);

    struct participants{
        mapping(address => uint) amountPaid;
        address[] redParticipants;
        address[] blackParticipants;
        address[] greenParticipants;
        uint numberOfRed;
        uint numberOfBlack;
        uint numberOfGreen;
    }
    mapping(address => uint) moneyInTokens;
    mapping(string => participants) IDOfGame;

    function payWinners(string memory gameID, uint colorWon) public{
        uint B = 1;
        uint R = 2;
        uint G = 3;
        if (colorWon == B){
            uint n = IDOfGame[gameID].numberOfBlack;
            for (uint i = 0; i<n; i++){
                address payTo = IDOfGame[gameID].blackParticipants[i];
                moneyInTokens[payTo] += IDOfGame[gameID].amountPaid[payTo] * 2;
            }
        }
        else if (colorWon == R){
            uint n = IDOfGame[gameID].numberOfRed;
            for (uint i = 0; i<n; i++){
                address payTo = IDOfGame[gameID].redParticipants[i];
                moneyInTokens[payTo] += IDOfGame[gameID].amountPaid[payTo] * 2;
            }

        }
        else if (colorWon == G){
            uint n = IDOfGame[gameID].numberOfGreen;
            for (uint i = 0; i<n; i++){
                address payTo = IDOfGame[gameID].greenParticipants[i];
                moneyInTokens[payTo] += IDOfGame[gameID].amountPaid[payTo] * 14;
            }
        }
    }

    function registerToRoulette(string memory gameID, uint colorBet, uint amountToBet) public returns(bool){
        uint B = 1;
        uint R = 2;
        uint G = 3;
        if (colorBet == B){
            IDOfGame[gameID].blackParticipants.push(msg.sender);
            IDOfGame[gameID].numberOfBlack++;
            require(moneyInTokens[msg.sender] >= amountToBet);
            moneyInTokens[msg.sender] -= amountToBet;
            IDOfGame[gameID].amountPaid[msg.sender] += amountToBet;
        }
        else if (colorBet == R){
            IDOfGame[gameID].redParticipants.push(msg.sender);
            IDOfGame[gameID].numberOfRed++;
            require(moneyInTokens[msg.sender] >= amountToBet);
            moneyInTokens[msg.sender] -= amountToBet;
            IDOfGame[gameID].amountPaid[msg.sender] += amountToBet;
        }
        else if (colorBet == G){
            IDOfGame[gameID].greenParticipants.push(msg.sender);
            IDOfGame[gameID].numberOfGreen++;
            require(moneyInTokens[msg.sender] >= amountToBet);
            moneyInTokens[msg.sender] -= amountToBet;
            IDOfGame[gameID].amountPaid[msg.sender] += amountToBet;
        }

        return true;

    }

    function depositTokens(uint amount) public payable returns(bool){
        require(amount <= balances[msg.sender]);
        balances[msg.sender] -= amount;
        moneyInTokens[msg.sender] += amount;
        emit Deposited(amount);
        return true;
    }

    function withdrawTokens (uint amount) public payable returns(bool){
        require(amount <= moneyInTokens[msg.sender]);
        moneyInTokens[msg.sender] -= amount;
        balances[msg.sender] += amount;
        emit Withdrawn(msg.sender, amount);
        return true;
    }
    

    // For Now everyone can run theese functions it will be changed when we specify all owners addresses
}