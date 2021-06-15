// SPDX-License-Identifier: MIT
pragma solidity <=0.8.5;

contract Token{

    struct locking {
        uint value;
        uint time_locked;
    }
    mapping(string => mapping(address => bool)) internal registeredToAirdrop;
    mapping(address => uint) internal balances;
    mapping(address => mapping(address => uint)) internal allowance;
    mapping(address => uint) internal airdropBalance;
    mapping(address => locking) internal lockedAmount;


    uint public totalSupply = 150000000 * 10 ** 18;
    string public name = "caishen.finance";
    string public symbol = "CFI";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);


    constructor(){
        balances[msg.sender] = totalSupply;
    }

    
    function transfer(address to, uint value) external  payable returns(bool){
        if (block.timestamp >= lockedAmount[msg.sender].time_locked){
            lockedAmount[msg.sender].time_locked = 0;
        }
        require(balances[msg.sender]- lockedAmount[msg.sender].value>= value, "Sorry you dont have enough tokens");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender,to,value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) external  returns(bool){
        require(balances[from] >= value, "Sorry you dont have enough tokens");
        require(allowance[from][msg.sender] >= value, "Allowance too low");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    } 
    
    function approve(address spender, uint value) external returns(bool){
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function balanceOf(address owner) public view returns(uint){
        return balances[owner];
    }

}
