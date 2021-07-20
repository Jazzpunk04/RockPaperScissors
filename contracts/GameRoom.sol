// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


// imports en remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract GameRoom {
    //using SafeMath for uint;

    
    address payable player1;
    address payable player2;
    uint bet;
    bool isFull;
    mapping (address => bytes32) moves;
    mapping (address => uint) cooldowns;
    mapping (address => uint) selection; //tijeras => 0; papel => 1; piedra => 2
    uint timeBetweenPlays = 5 minutes;
    bool isOpen;
    
    //Tiene sentido hacer esto??
    modifier isPlayer(){
        require(player1 == msg.sender || player2 == msg.sender);
        _;
    }

    modifier isTheHost(address _address){
        require(_address == player1);
        _;
    }

    event playerMove(address _player, uint time);
    event moveReveal(address _player1, address _player2);
    event emitWinner(address _winner);
    event emitDraw();
    event winnerPayed(address _winner, uint _bet);
    event playerTimeOut(address _player);
    event playerMoveRevealed(address _player0);
    event gameIsColsed();
    
    constructor (address payable _player1, uint _bet) payable { 
        player1 = _player1;
        bet = _bet;
        isFull = false;
        isOpen = true;
    }
    
    function setPlayer2(address payable _player2) external payable{
        require(_player2.balance >= bet); 
        player2 = _player2;
        isFull = true;
    }

        function getPlayer() internal view returns(uint) {
        if (msg.sender == player1){
            return 1;
        }else{
        return 2;
        }
    }
    
    function getBet() public returns (uint) {
        return bet;
    }

    function isFullGame() public returns (bool) {
        return isFull;
    }
    
    function declareMove(bytes32 _move) public isPlayer() {
        require(isOpen, "the game is already over, thanks for playing!");
        if (getPlayer() == 1) {
            require(moves[player1] == 0, "you already made a move"); //VER COMO ARREGLARLO
            changeMove(_move, player1, player2);
        } else {
        require(moves[player2] == 0, "you already made a move"); //VER COMO ARREGLARLO
            changeMove(_move, player2, player1);
        }
    }

    function changeMove(bytes32 _move, address payable _player, address payable _rival) internal {
        uint cooldown = block.timestamp;
        cooldowns[_player] = cooldown;
        if (cooldowns[_rival] != 0){
            if (cooldowns[_player] - cooldowns[_rival] > timeBetweenPlays) {
                emit playerTimeOut(_player);
                _rival.transfer(bet*2);
                isOpen = false;
                emit gameIsColsed();
                return;
            }
        }
        bytes32 move = _move;
        move = moves[_player];
        emit playerMove(_player, cooldown);
    }
    
    function revealMove(string memory _move, bytes32 _commitedMove) public isPlayer() {
        require(isOpen, "the game is already over, thanks for playing!");
        require(_commitedMove == keccak256(abi.encodePacked(_move)), "the moves are not the same");
        bytes memory moveInBytes = bytes(_move);
        if (moveInBytes[0] == 't'){
            uint moveNumber = 0;
            moveNumber = selection[msg.sender];        
        }
        if (moveInBytes[0] == 'p'){
            if (moveInBytes[1] == 'a') {
                uint moveNumber = 1;
                selection[msg.sender] = moveNumber;    
            } else if (moveInBytes[1] == 'i') {
                uint moveNumber = 2;
                selection[msg.sender] = moveNumber;        
            }
        }   
    }

    function declareWinner() public { //MATI tengo que ver como hacer para  verificar que ambos jugadores revelaron sus jugadas
        require(isOpen, "the game is already over, thanks for playing!");
        uint choice1 = selection[player1];
        uint choice2 = selection[player2];
        
        if (choice1 == 0) {
            if (choice2 == 0) {
                player1.transfer(bet);
                player2.transfer(bet);
                emit emitDraw();
            }
            else if (choice2 == 1) {
                player1.transfer(bet*2);
                emit emitWinner(player1);
            }
            else if (choice2 == 2) {
                player2.transfer(bet*2);
                emit emitWinner(player2);
            }
        }
        else if (choice1 == 1) {
            if (choice2 == 0) {
                player2.transfer(bet*2);
                emit emitWinner(player2);}
            else if (choice2 == 1) {
                player1.transfer(bet);
                player2.transfer(bet);
                emit emitDraw();
            }
            else if (choice2 == 2) {
                player1.transfer(bet*2);
                emit emitWinner(player1);
            }
        }
        else if (choice1 == 2) {
            if (choice2 == 0) {
                player1.transfer(bet*2);
                emit emitWinner(player1);
            }
            else if (choice2 == 1) {
                player2.transfer(bet*2);
                emit emitWinner(player2);}
            else if (choice2 == 2) {
                player1.transfer(bet);
                player2.transfer(bet);
                emit emitDraw();
            }
        }
        isOpen = false;
        emit gameIsColsed();
    }
}