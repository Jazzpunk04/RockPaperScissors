// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Lobby is Ownable{

    struct user{
        uint id;
        uint balance;
    }
    
    Game[] games;
    mapping (address => Game) playerToGame;

    struct Game {
        address phost;
        address pjoined;
        uint bet;
        bool isFull;
    }

    function createGame(uint bet) public {
        Game memory game = Game(msg.sender, address(0x0), bet, false);
        games.push(game);
    }

    function joinGame(uint maxBet) public {
        for(uint i = 0; i < games.length; i++){
            if (games[i].isFull == false && games[i].bet < maxBet) {
                games[i].isFull = true;
                games[i].pjoined = msg.sender;
                return;
            }
        }
    }

    function closeGame() public {
        Game storage game = playerToGame[msg.sender];
        require(game.phost == msg.sender);
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
}