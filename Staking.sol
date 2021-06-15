// SPDX-License-Identifier: MIT
pragma solidity <=0.8.5;

import "./Token.sol";

contract Staking is Token{

    event StakingRegistration(address indexed from, address indexed to, uint value);
    event StakingWithdraw(address indexed to, uint value);

    struct stakingInfo{
        address[] participants;
        uint timeStaking;
        uint numberOfParticipants;
        uint fullDestributionAmount;
        mapping(address => uint) stakedValueOfAddress;
        mapping(address => bool) isAlreadyRegistered;
        mapping(address => uint) percentageOfPool;
    }

    mapping(string => stakingInfo) public stakingInformations;
    address addressOfStaking = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; // to test;

    function startLockedStaking(uint time, uint amountToDistribute, string memory stakingID) public returns(bool){
        require(balances[addressOfStaking] >= amountToDistribute, "Not enough money on Staking address");
        stakingInformations[stakingID].timeStaking = block.timestamp + time * 1 hours;
        stakingInformations[stakingID].fullDestributionAmount = amountToDistribute;
        balances[addressOfStaking] -= amountToDistribute;
        return true;
    }

    function distributeTokens(string memory stakingName) public returns(bool){
        uint n = stakingInformations[stakingName].numberOfParticipants;
        uint amountToGiveEveryFourHoursForOnePerson = uint(((stakingInformations[stakingName].fullDestributionAmount)/(stakingInformations[stakingName].timeStaking / 4)));
        for (uint i = 0; i<n; i++){
            address person = stakingInformations[stakingName].participants[i];
            uint percentageAmountToGet = uint((stakingInformations[stakingName].percentageOfPool[person] * 100) / amountToGiveEveryFourHoursForOnePerson);
            stakingInformations[stakingName].stakedValueOfAddress[person] += (percentageAmountToGet/100) * amountToGiveEveryFourHoursForOnePerson;
        }
        return true;
    }

    function registerToStaking(string memory stakingName, uint amountToStake) public returns(bool){
        require(stakingInformations[stakingName].isAlreadyRegistered[msg.sender] == false, "you already participate in that Staking");
        require(balances[msg.sender] >= amountToStake);
        stakingInformations[stakingName].participants.push(msg.sender);
        stakingInformations[stakingName].numberOfParticipants++;
        balances[msg.sender] -= amountToStake;
        balances[addressOfStaking] += amountToStake;
        stakingInformations[stakingName].stakedValueOfAddress[msg.sender] += amountToStake;
        stakingInformations[stakingName].percentageOfPool[msg.sender] = amountToStake;
        emit StakingRegistration(msg.sender, addressOfStaking, amountToStake);
        return true;
    }
    
    function recieveStakedTokens(string memory stakingName, uint amountToRecieve) public returns(bool){
        require(block.timestamp >= stakingInformations[stakingName].timeStaking, "You cant get your tokens yet");
        uint howMuchStaked = stakingInformations[stakingName].stakedValueOfAddress[msg.sender];
        require(amountToRecieve <= howMuchStaked);
        balances[msg.sender] += amountToRecieve;
        stakingInformations[stakingName].stakedValueOfAddress[msg.sender] -= amountToRecieve;
        emit StakingWithdraw(msg.sender, amountToRecieve);
        return true;
    }
}