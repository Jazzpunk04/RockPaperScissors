// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


// imports en remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";


contract GameRoom {
    using SafeMath for uint;

    address payable player1;
    address payable player2;
    uint bet;
    bool isFull;
    mapping (address => bytes32) moves;
    mapping (address => uint) cooldowns;
    mapping (address => bytes32) commitedMoves;
    mapping (address => uint) selection; //tijeras => 0; papel => 1; piedra => 2
    uint timeBetweenPlays = 5 minutes;
    uint revealMoveCounter;
    bool isOpen;
    
    //Tiene sentido hacer esto??
    modifier isPlayer(){
        require(player1 == msg.sender || player2 == msg.sender, "you are not a player");
        _;
    }

    modifier isTheHost(address _address){
        require(_address == player1);
        _;
    }
    modifier playersHaveDeposited(uint totalAmout){
        require(address(this).balance == bet.mul(2), "All players must set bet to play");
        _;
    }

    event playerMove(address _player, uint time);
    event emitWinner(address _winner);
    event emitDraw();
    event winnerPayed(address _winner, uint _bet);
    event playerTimeOut(address _player);
    event playerMoveRevealed(address _player0);
    event bothPlayersRevealed();
    event gameIsColsed();
    
    constructor (address payable _player1, uint _bet) payable { 
        player1 = _player1;
        bet = _bet;
        isFull = false;
        revealMoveCounter = 0;
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
    
    function getBet() public view returns (uint) {
        return bet;
    }

    function isFullGame() public view returns (bool) {
        return isFull;
    }

    function started() external view returns (bool) {
        return moves[player1] != 0 || moves[player2] != 0;
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
                _rival.transfer(bet.mul(2));
                isOpen = false;
                emit gameIsColsed();
                return;
            }
        }
        moves[_player] = _move;
        emit playerMove(_player, cooldown);
    }
    
     function revealMove(string memory _move, bytes32 _commitedMove) public isPlayer() {
        require(isOpen, "the game is already over, thanks for playing!");
        if (getPlayer() == 1) {
            require(commitedMoves[player1] == 0, "you already commited your move"); //VER COMO ARREGLARLO
            revealMoveLogic(_move,_commitedMove);
            commitedMoves[msg.sender] = _commitedMove;
            revealMoveCounter.add(1);
        } else {
        require(commitedMoves[player2] == 0, "you already commited your move"); //VER COMO ARREGLARLO
            revealMoveLogic(_move,_commitedMove);
            commitedMoves[msg.sender] = _commitedMove;
            revealMoveCounter.add(1);
        }
        if (revealMoveCounter == 2) {
            emit bothPlayersRevealed();
        }
    }
    
    
    function revealMoveLogic(string memory _move, bytes32 _commitedMove) internal{
        require(isOpen, "the game is already over, thanks for playing!");
        require(_commitedMove == keccak256(abi.encodePacked(_move)), "the moves are not the same");
        require(revealMoveCounter <= 2,"Both players revealed their move");
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
        emit playerMoveRevealed(msg.sender); 
    }

    function declareWinner() public { //MATI tengo que ver como hacer para  verificar que ambos jugadores revelaron sus jugadas
        require(isOpen, "the game is already over, thanks for playing!");
        require(revealMoveCounter == 2, "both players have to reveal their move");
        //tijeras => 0; papel => 1; piedra => 2
        uint choice1 = selection[player1];
        uint choice2 = selection[player2];
        
        if(choice1 == choice2){
             player1.transfer(bet);
             player2.transfer(bet);
             emit emitDraw();
        }else if (choice1 == 0 && choice2 == 1 || choice1 == 1 && choice2 == 2 || choice1 == 2 && choice2 == 0){
            player1.transfer(bet.mul(2));
            emit emitWinner(player1);
        }else{
            player2.transfer(bet.mul(2));
            emit emitWinner(player2);
        }
        isOpen = false;
        emit gameIsColsed();
    }
    
    
    
    //for testing
    function getRevealMoveCounter() public view returns(uint count){
        return revealMoveCounter;
    }
    
    function getPlayer1AndBalance() public view returns (address _player1,uint256 _p1Balance){
        return(player1,player1.balance);
    }
     function getPlayer2AndBalance() public view returns (address _player2,uint256 _p2Balance){
        return(player2,player2.balance);
    }
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    function deposit() external payable {
        require(msg.sender.balance > bet, "You dont have the enough money");
        require(msg.value == bet, "deposit the bet amount");
    }
 }
