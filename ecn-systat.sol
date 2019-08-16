/* 
Statistics for the CrackNet
CrackNet, 2019, Released under the MIT License
*/

pragma solidity ^0.5.8;

library SafeMath {
	 function add(uint a, uint b) internal pure returns(uint c)
	 {
	 	c=a+b;
		require(c>=a);
	 }
	 function sub(uint a, uint b) internal pure returns(uint c)
	 {
		c=a-b;
		require(c<=a);	 
	 }
	 function mul(uint a, uint b) internal pure returns(uint c)
	 {
		c=a*b;	 
		require(a==0||c/a==b);
	 }
	 function div(uint a,uint b) internal pure returns(uint c)
	 {
		require(b>0);
		c = a/b;	 
	 }
 }


contract Owned{
	address public owner;
	address public newOwner;
	
	event OwnershipTransferred(address indexed _from, address indexed _to);
	
	constructor() public{
		owner=msg.sender;	
	}
	modifier onlyOwner{
		require(msg.sender==owner);
		_;	
	}
	function transferOwnership(address _newOwner) public onlyOwner
	{
		newOwner=_newOwner;	
	}
	function acceptOwnership() public{
		require(msg.sender==newOwner);
		emit OwnershipTransferred(owner,newOwner);
		owner=newOwner;
		newOwner=address(0);	
	}

}

contract GroupOwned is Owned{
    
    event GroupTransferred(address indexed from,address indexed to);
    
    //0 for not in , integers count the increasing priority in the group 
    mapping(bytes => mapping(address => int8)) public groups;
  //  mapping(bytes32 => uint32) _group_count;
    

    modifier onlySuperior(bytes memory gname,address subject){
        require((groups[gname][msg.sender]>groups[gname][subject])||(msg.sender==owner));
        _;
    }
    
    modifier onlyGroup(bytes memory gname,int8 level)
    {
        require(groups[gname][msg.sender]>=level);
        _;
    }
   
    function groupmod(bytes memory gname,address user,int8 priority) internal returns(bool)
    {
        groups[gname][user]=priority;
        return true;
    }

    function CGroupMod(bytes memory gname, address user,int8 priority) public onlySuperior(gname,user) returns(bool)
    {		  
		  require((groups[gname][msg.sender]>priority)||(msg.sender==owner));
        if(groupmod(gname,user,priority))
        {
            return true;
        }
        return false;
    }  
 }

contract Child is Owned,GroupOwned
{
	address public root;
	address public token;
	
	function setRoot(address newroot) public onlyGroup('child_manage',2) returns(bool)
	{
		root=newroot;
		return true;	
	}
	
	function setToken(address newToken) public onlyGroup('child_manage',2) returns (bool)
	{
		token=newToken;
		return true;	
	}
}
/*
contract ECNRoot{
    function components(bytes memory name,uint ind) public view returns (address);
}
*/

contract ECNSysStat is Owned,GroupOwned,Child
{
	 using SafeMath for uint;	
    
    string public symbol;
    string public name;
    
    mapping(bytes=>uint) public records;
    mapping(bytes=>uint256) public totalReward;
    mapping(bytes=>uint256) public totalEarned;
    mapping(bytes=>uint) public numChallenges;
    mapping(bytes=>uint) public activeChallenges;
    mapping(bytes=>uint) public numSolved;

    constructor() public
    {
        symbol="ECNSYSSTAT";
        name="E-CrackNet System Statistics";
        groupmod('stat',owner,1);
    }
    

    
    function CSetRecord(bytes memory alg,uint rec) public onlyGroup('stat',1) returns(bool)
    {
        if(setRecord(alg,rec))
        {
            return true;
        }
        return false;
    }
    
    function CSetTReward(bytes memory alg,uint256 reward) public onlyGroup('stat',1) returns(bool)
    {
        if(setTReward(alg,reward))
        {return true;}
        return false;
    }
    
    function CIncTReward(bytes memory alg,uint256 amount) public onlyGroup('stat',1) returns(bool)
    {
		 totalReward[alg]=totalReward[alg].add(amount);
		 return true;    
    }
    function CDecTReward(bytes memory alg,uint256 amount) public onlyGroup('stat',1) returns(bool)
    {
		 totalReward[alg]=totalReward[alg].sub(amount);
		 return true;    
    }

    function CIncTEarned(bytes memory alg,uint256 earned) public onlyGroup('stat',1) returns(bool)
    {
        if(IncTEarned(alg,earned))
        {return true;}
        return false;
    }
    
    function CIncNumSolved(bytes memory alg) public onlyGroup('stat',1) returns(bool)
    {
        if(IncNumSolved(alg))
        {return true;}
        return false;
    }

	 function CIncNumChal(bytes memory alg) public onlyGroup('stat',1) returns(bool)
	 {
		numChallenges[alg]=numChallenges[alg].add(1);
		return true;	 
	 }   
   
	 function CSetActChal(bytes memory alg,uint num) public onlyGroup('stat',1) returns(bool)
	 {
		activeChallenges[alg]=num;
		return true;	 
	 }   
    
    function CIncActChal(bytes memory alg) public onlyGroup('stat',1) returns(bool)
    {
		 activeChallenges[alg]=activeChallenges[alg].add(1);
		 return true;    
    }   
    function CDecActChal(bytes memory alg) public onlyGroup('stat',1) returns(bool)
    {
		 activeChallenges[alg]=activeChallenges[alg].sub(1);
		 return true;   
    } 
    
    
    
    function setRecord(bytes memory alg,uint rec) internal returns(bool)
    {
        records[alg]=rec;
        return true;
    }   
    
    function setTReward(bytes memory alg,uint256 reward) internal returns(bool)
    {
        totalReward[alg]=reward;
        return true;
    }

    function IncTEarned(bytes memory alg,uint256 earned) internal returns(bool)
    {
        totalEarned[alg]=totalEarned[alg].add(earned);
        return true;
    }
    
    function setNumCh(bytes memory alg,uint num) internal returns(bool)
    {
        numChallenges[alg]=num;
        return true;
    }
    
    function IncNumSolved(bytes memory alg) internal returns(bool)
    {
        numSolved[alg]=numSolved[alg].add(1);
        return true;
    }
}
