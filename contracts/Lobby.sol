// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Lobby {

    struct user{
        uint id;
        uint balance;
    }
    
    Game[] games;
    mapping (uint => address) users;

    struct Game {
        address phost;
        address pjoined;
        uint bet;
        bool isFull;
    }

    function createGame() public {
        Game memory game = Game(msg.sender, address(0x0), 0, false);
        games.push(game);
    }
}