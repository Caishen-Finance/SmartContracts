// SPDX-License-Identifier: MIT
pragma solidity <=0.8.5;

import "./Token.sol";

contract Referrals is Token{

    event ReferralsWithdraw(address to, uint amount);
    
    struct RefsInfo{
        address[] peopleRefered;
        uint amountOfPeopleRefered;
        uint bountyTaken;
    }

    mapping(address => RefsInfo) ReferalsInformation;

    function checkRef (address ad) private view returns(bool){
        for (uint i = 0; i<ReferalsInformation[msg.sender].amountOfPeopleRefered; i++){
            if (ReferalsInformation[msg.sender].peopleRefered[i] == ad){
                return false;
            }
        }
        return true;
    }

    function addRef(address referedAddress) public returns(bool){
        require(checkRef(referedAddress) == true, "sorry you already did invite that person");
        ReferalsInformation[msg.sender].peopleRefered.push(referedAddress);
        ReferalsInformation[msg.sender].amountOfPeopleRefered += 1;
        ReferalsInformation[msg.sender].bountyTaken += 100;
        return true;
    }

    function withdrawReferral(uint amount) public returns(bool){
        require(ReferalsInformation[msg.sender].bountyTaken >= amount);
        ReferalsInformation[msg.sender].bountyTaken -= amount;
        balances[msg.sender] += amount;
        emit ReferralsWithdraw(msg.sender, amount);
        return true;
    }

}