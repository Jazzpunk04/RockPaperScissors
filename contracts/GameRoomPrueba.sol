// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


// imports en remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract GameRoomPrubea {

    using SafeMath for uint;


    address payable player1;
    address payable player2;
    uint bet;
    bool isFull;
    mapping (address => bytes32) moves;
    uint amountOfMoves;
    uint gameEndTime;
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
    
    constructor  (address payable _player1, uint _bet) payable { 
        player1 = _player1;
        bet = _bet;
        isFull = false;
        amountOfMoves = 0;
        isOpen = true;
    }
    
    function setPlayer2(address payable _player2) external payable{
        require(_player2.balance >= bet); 
        player2 = _player2;
        isFull = true;
        gameEndTime = block.timestamp + 300 seconds;
    }

        function getPlayer() internal view returns(uint) {
        if (msg.sender == player1){
            return 1;
        }else{
            return 2;
        }
    }

    function declareMove(string memory _move) public isPlayer() {
        require(block.timestamp < gameEndTime);
        require(isOpen, "the game is already over, thanks for playing!");

        require (keccak256(abi.encodePacked((_move))) == keccak256(abi.encodePacked(("rock")))  ||
                 keccak256(abi.encodePacked((_move))) == keccak256(abi.encodePacked(("paper"))) ||
                 keccak256(abi.encodePacked((_move))) == keccak256(abi.encodePacked(("scissors"))));

        if (getPlayer() == 1) {
            setMove(_move, player1);
        } else {
            setMove(_move, player2);
        }
    
    }

    function setMove(string memory _move, address payable _player) internal {
        require(moves[_player] > 0) /**Este jugador ya jugo */;
        moves[_player] = keccak256(abi.encodePacked((_move)));
        amountOfMoves++;
        emit playerMove(_player,block.timestamp);

    }
    
    function revealMoves() public isPlayer() {
        require(block.timestamp > gameEndTime);
        if(amountOfMoves == 2){
            declareWinner();
        }else if(amountOfMoves == 1){
            if(moves[player1] > 0){
                player1.transfer(bet*2);
                emit emitWinner(player1);
            }else{
                player2.transfer(bet*2);
                emit emitWinner(player2);
            }
        }else{
            player1.transfer(bet);
            player2.transfer(bet);
        }
        isOpen = false;
        emit gameIsColsed();   
    }

    function declareWinner() internal {
       bytes32 rockHexa = keccak256(abi.encodePacked(("rock")));
        bytes32 paperHexa = keccak256(abi.encodePacked(("paper")));
        bytes32 scissorsHexa = keccak256(abi.encodePacked(("scissors")));
        bytes32 choiceP1 = moves[player1];
        bytes32 choiceP2 = moves[player2];

        if(choiceP1 == choiceP2){
                player1.transfer(bet);
                player2.transfer(bet);
                emit emitDraw(); 
         }

         //Player 1 Wins
         if(choiceP1 == rockHexa && choiceP2 == scissorsHexa || choiceP1 == paperHexa && choiceP2 == rockHexa || choiceP1 == scissorsHexa && choiceP2 == paperHexa){
             player1.transfer(bet*2);
             emit emitWinner(player1);
         }else{ 
             //player 2 wins
              player2.transfer(bet*2);
              emit emitWinner(player2);
         }          
    }
}