// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./Lobby.sol"

// imports en remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Game is Lobby {

    uint timeBetweenPlays = 5 minutes;    //si el otro jugador no hizo la jugada => iniciar el cooldown

    struct Player {
        address name;
        uint encryptedMove;
        uint cd;
        uint bet;
        bool host;
    }

    event playerMove(Player _payer, uint time);
    event moveReveal(Player _player1, Player _player2);

}