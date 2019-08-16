/*
Root E-CrackNet contract, contains all component addresses and metadata

Copyright CrackNet, 2019, All Rights Reserved,
This software may not be redistributed, modified or published by any other individual.
*/


pragma solidity ^0.5.8;


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
	address public token;
		
	function setToken(address newToken) public onlyGroup('child_manage',2) returns (bool)
	{
		token=newToken;
		return true;	
	}
}

contract ECNRoot is Owned,GroupOwned,Child{
    
    string public name;
    string public symbol;
    
    /*
    Names for contract components:
    "METADATA","STORAGE","REDEEM","USTAT","SYSTAT","GROUP","GROUP-REDEEM"
    */
    mapping(bytes=>mapping(uint=>address)) public components;
    
    //secret generation algorithms
    mapping(bytes=>mapping(uint=>address)) public secret;
    
    constructor() public
    {
        symbol="CNROOT";
        name="CrackNet Root v1.0";
        
        groupmod('component',owner,2);
        groupmod('secret',owner,2);
    }
    
    /*
    function getComponent(bytes memory cname,uint ind) public view returns(address)
    {
        return components[cname][ind];
    }*/
    
    
    //used by constructor
    function setComponent(bytes memory cname,uint ind, address ctract) internal returns(bool)
    {
        components[cname][ind]=ctract;
        return true;
    }
    
    function CSetComponent(bytes memory cname,uint ind,address ctract) public onlyGroup('component',2) returns(bool)
    {
        if(setComponent(cname,ind,ctract)) 
        {
            return true;
        }
        else{
            return false;
        }
    }
    
    function setSecret(bytes memory secrettype ,uint ind,address ctract) public onlyGroup('secret',2) returns (bool)
    {
        secret[secrettype][ind]=ctract;
        return true;
    }
    
    /*
    function getSecret(bytes memory secrettype,uint ind) public view returns(address)
    {
        return secret[secrettype][ind];
    }*/
}
