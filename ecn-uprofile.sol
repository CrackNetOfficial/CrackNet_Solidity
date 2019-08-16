/*
Non statistical user information

CrackNet , 2019, Released under MIT Attribution License
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


contract UProf is Owned,GroupOwned,Child
{
    string public name;
	 string public symbol;
    
    //IPFS:// HTTPS:// link to machine info JSON file
    /*mapping(address=>bytes) public machineInfo;
    mapping(address=>bytes) public machineMedia;
    mapping(address=>bytes32) public machineName;
    mapping(address=>bytes) public crackerSoc; //social media links as JSON file
    */
    //ipfs or https link to cprofile JSON
    /*
    cprofile:{
    	spec:
    	media:
    	name:
    	social:
    }
    */
    mapping(address=>bytes) public cprofile;
    
    constructor() public
    {
        root=address(0);
        token=address(0);
		  name="CrackNet Alpha v1.0 User Profiles";
		  symbol="UPROF";
    }
 
	 function setCProfile(bytes memory lnk) public returns(bool)
	 {
	 	 require(msg.sender!=address(0));
		 cprofile[msg.sender]=lnk;
		 return true;	 
	 } 
 
 /*
    function setMachineInfo(bytes memory lnk) public returns(bool)
    {
        require(msg.sender!=address(0));
        machineInfo[msg.sender]=lnk;
        return true;
    }

    function setMachineMedia(bytes memory lnk) public returns(bool)
    {
        require(msg.sender!=address(0));
        machineMedia[msg.sender]=lnk;
        return true;
    }
    
    funciton setMachineName(bytes32 memory mname) public returns(bool)
    {
        require(msg.sender!=address(0));
        machineName[msg.sender]=mname;
        return true;
    }*/
}
