/* 
E-CrackNet User Statistics Contract

Copyright CrackNet, 2019, released under MIT License
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

contract ECNUstat is Owned,GroupOwned,Child
{
    using SafeMath for uint;
    
    string public name;
    string public symbol;
    
    //number cracked for each algorithm
    mapping(address=>mapping(bytes=>uint)) public crackScore;
    mapping(address=>mapping(bytes=>uint256)) public earned;
	 mapping(address=>mapping(bytes=>uint)) public record;    
    
    constructor() public
    {
        name="E-CrackNet User Statistics";
        symbol="ECNUSTAT";
        //root=address(0);
        //token=address(0);
        
        //add stat setting privileges for the redeem contract
        groupmod('stat',owner,1);
    }
    
    function incScore(address user, bytes memory alg) internal returns(bool)
    {
        crackScore[user][alg]=crackScore[user][alg].add(1);
        return true;
    }
    
    function incEarned(address user,bytes memory alg,uint256 reward) internal returns(bool)
    {
        earned[user][alg]=earned[user][alg].add(reward);
        return true;
    }
    
    function CIncScore(address user,bytes memory alg) public onlyGroup('stat',1) returns(bool)
    {
        if(incScore(user,alg))
        {
            return true;
        }
        return false;
    }
    
    function CIncEarned(address user,bytes memory alg,uint256 reward) public onlyGroup('stat',1) returns(bool)
    {
        if(incEarned(user,alg,reward))
        {return true;}
        return false;
    }
    
    function CSetRecord(address user,bytes memory alg,uint rec) public onlyGroup('stat',1) returns(bool)
    {
		record[user][alg]=rec;
		return true;    
    }
}
