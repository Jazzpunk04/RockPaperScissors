// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

// imports en remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Lobby is Ownable{

    struct Game {
        address payable player1;
        address payable player2;
        uint bet;
        bool isFull;
    }
    
    Game[] games;
    mapping (address => Game) playerToGame;

    modifier isPlaying(Game memory _game) {
        require(msg.sender == _game.player1 || msg.sender == _game.player2, "usted no es un participante del jeugo");
        _;
    }

    modifier isHost(Game memory _game) {
        require(msg.sender == _game.player1, "usted no es el anfitrion del juego");
        _;
    }
    event NewGame(address host, uint bet, bool isFull);
    
    function createGame(uint bet) public payable {
        Game memory game = Game(payable(msg.sender), payable(address(0x0)), bet, false);
        games.push(game);
        emit NewGame(msg.sender,bet,false);
    }
    
    function findGame(uint minBet, uint maxBet) external payable {
        for(uint i = 0; i < games.length; i++){
                if (games[i].isFull == false && games[i].bet < maxBet && games[i].bet > minBet) {
                joinGame(games[i]);
                Game memory joinedGame = games[i];
                games[i] = games[games.length-1];
                delete games[games.length-1];
                // return joinedGame;
            }
        }
    }

    function joinGame(Game memory _game) internal view {
        _game.isFull = true;
        _game.player2 = payable(msg.sender);
    }

    // function closeGame(Game memory _game) public isHost(_game) {
    //     Game storage game = playerToGame[msg.sender];
    //     uint pos = 0; //por ahora
    //     delete games[pos];
    // }
    

     function play(uint  _movePlayer1, uint  _movePlayer2, Game memory _game) public isPlaying(_game){
         require(_movePlayer1 >=0 && _movePlayer1 <=2 && _movePlayer2 >=0 && _movePlayer2 <=2);
         
         uint playerWiner = checkPlay(_movePlayer1,_movePlayer2);
         if(playerWiner == 0){ // esto es una idea nomas, no esta bien aplicada la recursividad
             play(_movePlayer1,_movePlayer2,_game);
         }else if (playerWiner == 1){
             _game.player1.transfer(_game.bet);
         }else{ 
             _game.player2.transfer(_game.bet);
         }
         
     }
     
     function checkPlay(uint _movePlayer1, uint _movePlayer2) internal returns (uint winer) {
         // 0 = Rock
         // 1 = Paper
         // 2 = Scissors
         //Tie
         if(_movePlayer1 == 0 && _movePlayer2 == 0 || _movePlayer1 == 1 && _movePlayer2 == 1 
            || _movePlayer1 == 2 && _movePlayer2 == 2){
             return (0); // retuns a 0 so its a tie
         }
         //Player 1 Wins
         if(_movePlayer1 == 0 && _movePlayer2 == 2 ||
            _movePlayer1 == 1 && _movePlayer2 == 0 ||
            _movePlayer1 == 2 && _movePlayer2 == 1){
                
             return (1); // retuns a 1 so player 1 Wins
             
         }else return(2);
         
     }
}