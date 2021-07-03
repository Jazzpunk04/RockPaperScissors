// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./Lobby.sol";

// imports en remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Game is Lobby {
    
    struct Player {
        address name;
        uint encryptedMove;
        uint cd;
    }

    constructor (address _player1, address _player2, uint _bet) {
        player1.name = _player1;
        player2.name = _player2;
        bet = _bet;

    }
    
    uint timeBetweenPlays = 5 minutes;    //si el otro jugador no hizo la jugada => iniciar el cooldown
    Player player1;
    Player player2;
    uint bet;

    event playerMove(Player _payer, uint time);
    event moveReveal(Player _player1, Player _player2);
    event declareWinner(Player _winner);


    modifier isPlaying(address _address){
        require(_address == player1.name || _address == player2.name);
        _;
    }

    modifier isTheHost(address _address){
        require(_address == player1.name);
        _;
    }

    function getPlayer() internal view returns(bool) {
        return msg.sender == player1.name;
    }

}