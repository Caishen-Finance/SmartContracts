// SPDX-License-Identifier: MIT
pragma solidity <=0.8.5;

import "./Token.sol";

contract Airdrops is Token {

    address airDropAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; // to test;
    address[] internal listOfWinners;
    uint public time;
    uint public withdrawTime;

    struct airDropInfo {
        uint numOfWinners;
        uint moneyToGive;
        uint lockUpPeriod;
        uint amountOfPeople;
        address[] peopleIn;
    }

    mapping(string => airDropInfo) public airDropInformations;

    modifier notRegisteredAlready(string memory airDropName){
        require(registeredToAirdrop[airDropName][msg.sender] == false);
        _;
    }

    modifier hasMoneyToLock(){
        require(balances[msg.sender] > 0);
        _;
    }

    modifier hasMoneyToAirdrop(uint valueToGive){
        require(balances[airDropAddress] > valueToGive, "Airdrop Main Address doesn't have enough money");
        _;
    }

    modifier didRegistrationTimePass(){
        require(block.timestamp < block.timestamp + time * 1 hours);
        _;
    }

    function registerToAirDrop(string memory airDropName) public didRegistrationTimePass returns(bool){
        registeredToAirdrop[airDropName][msg.sender] = true;
        airDropInformations[airDropName].amountOfPeople += 1;
        airDropInformations[airDropName].peopleIn.push(msg.sender);
        return true;
    }

    function random(string memory airDropName) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, airDropInformations[airDropName].peopleIn)));
    }

    function pickWinner(string memory airDropName) private view returns(address){
        uint length1 = airDropInformations[airDropName].amountOfPeople;
        uint index=random(airDropName)%length1;
        address winner = airDropInformations[airDropName].peopleIn[index];
        return winner;
    }

    function withdrawAirdrop(uint amount) public payable returns(bool){
        require(amount <= airdropBalance[msg.sender], "you dont have enough money");
        require(block.timestamp <= withdrawTime);
        balances[msg.sender] += amount;
        airdropBalance[msg.sender] -= amount;
        emit Transfer(address(0), msg.sender, amount);
        return true;
    }

    function startAirdrop(uint numOfTokens, uint numOfWinners, uint timeToJoin, uint lockUpPeriod, string memory airDropName) public hasMoneyToAirdrop(numOfTokens) payable returns(bool){
        balances[airDropAddress] -= numOfTokens;
        time = 0;
        time = timeToJoin;
        uint moneyToGive = numOfTokens/numOfWinners;
        withdrawTime = block.timestamp + lockUpPeriod * 1 hours;
        airDropInformations[airDropName].numOfWinners = numOfWinners;
        airDropInformations[airDropName].moneyToGive = moneyToGive;
        airDropInformations[airDropName].lockUpPeriod = lockUpPeriod;
        return true;
    }   
    
    function drawWinners(string memory airDropName) public returns(bool){
        uint end = airDropInformations[airDropName].numOfWinners;
        for (uint i = 0; i<end; i++){
            listOfWinners.push(pickWinner(airDropName));
            airdropBalance[listOfWinners[i]] = airDropInformations[airDropName].moneyToGive;
        }
        return true;
    }
}