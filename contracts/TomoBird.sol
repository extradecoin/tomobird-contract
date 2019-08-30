pragma solidity ^0.4.25;


/**
 *Submitted for verification at Etherscan.io on 2018-11-02
*/

contract Owner {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address _owner) public {
        owner = _owner;
    }

    function changeOwner(address _newOwnerAddr) public onlyOwner {
        require(_newOwnerAddr != address(0));
        owner = _newOwnerAddr;
    }
}
/* *
* safe math
*/
contract DSSafeAddSub {

    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b >= a);
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        if (!safeToAdd(a, b)) revert();
        return a + b;
    }

    function safeToSubtract(uint a, uint b) internal returns (bool) {
        return (b <= a);
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        if (!safeToSubtract(a, b)) revert();
        return a - b;
    }
}


contract TomoBird is Owner,DSSafeAddSub {
    
    struct Bird {
        uint score;
    }

    /** vars */
    // Funds distributor address.
    address public fundsDistributor;
    uint public birdPrice = 0.1 ether;
    uint public pointPrice = 0.005 ether;
    // Game status.
    bool public isActive = true;
    // The variable that indicates game status switching.
    bool public toogleStatus = false;
    mapping (address => Bird) public players;
    address[] public addPlayers;

    /* events */
    event ChangePriceLog(uint _birdPrice);
    event BuyBird(address _address, uint _birdPrice);
    event UpdateScore(address _address, uint score);
    event DistributeTOMO(address _address, uint score, uint tomo);
    event Deposit(address _address, uint amount);

    constructor(address distributor) public Owner(msg.sender)
    {
        fundsDistributor = distributor;
    }
    
    function deposit() payable public onlyOwner {
       emit Deposit(msg.sender, msg.value);
    }
    
     function toogleActive() public onlyOwner() {
        if (!isActive) {
            isActive = true;
        } else {
            toogleStatus = !toogleStatus;
        }
    }

    function buyBird() payable public{
        require(isActive);
        require(msg.value == birdPrice);
        players[msg.sender] = Bird(0);
        addPlayers.push(msg.sender);
        emit BuyBird(msg.sender, birdPrice);
    }
    
    function clameTOMO() public onlyOwner {
        fundsDistributor.transfer(address(this).balance);
    }
    
    function distributeTOMO() public onlyOwner {
        for (uint i=0; i< addPlayers.length; i++) {
            Bird bird = players[addPlayers[i]];
            uint score = bird.score;
            if(score > 0){
                players[addPlayers[i]] = Bird(0);
                addPlayers[i].transfer(pointPrice*score);
                emit DistributeTOMO(addPlayers[i], score, pointPrice*score);
            }
        }
    }
    
    function updateScore(uint score) public {
        Bird bird = players[msg.sender];
        bird.score = score;
        emit UpdateScore(msg.sender, score);
    }

    function changeBirdPrice(uint _birdPrice) public onlyOwner  {
        birdPrice = _birdPrice;
        emit ChangePriceLog(_birdPrice);
    }
    
    function getBirdPrice() constant returns (uint) {
        return birdPrice;
    }
    
    function getScore(address _address) public returns (uint) {
        Bird bird = players[msg.sender];
        return bird.score;
    }
    
    

}