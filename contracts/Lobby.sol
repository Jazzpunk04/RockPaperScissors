// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Lobby is Ownable{

    struct Player{
        uint id;
        uint balance;
    }
    
    Game[] games;
    mapping (address => Game) playerToGame;

    struct Game {
        address player1;
        address player2;
        uint bet;
        bool isFull;
    }

    modifier isPlaying(Game memory _game) {
        require(msg.sender == _game.player1 || msg.sender == _game.player2, "usted no es un participante del jeugo");
        _;
    }

    modifier isHost(Game memory _game) {
        require(msg.sender == _game.player1, "usted no es el anfitrion del juego");
        _;
    }

    function createGame(uint bet) public payable {
        Game memory game = Game(msg.sender, address(0x0), bet, false);
        games.push(game);
    }

    function joinGame(uint maxBet) public payable {
        for(uint i = 0; i < games.length; i++){
            if (games[i].isFull == false && games[i].bet < maxBet) {
                games[i].isFull = true;
                games[i].player2 = msg.sender;
                return;
            }
        }
    }

    function closeGame(Game memory _game) public isHost(_game) {
        Game storage game = playerToGame[msg.sender];
        uint pos = findGame(game);
        delete games[pos];
    }

    function findGame(Game storage _game) internal returns (uint) {
        return 0; //hasta que vea como usar un equals
        /*for (uint i = 0; i < games.length; i++) {
            if (games[i].equals(_game)) {
                return i;
            }
        }*/
    }

    function play(string memory _move, Game memory _game) external isPlaying(_game){
        
    }
}