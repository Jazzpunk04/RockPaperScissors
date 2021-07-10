// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./Lobby.sol";

// imports en remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Session is Lobby {
    
    struct Player {
        uint number;
        address name;
        byte32 move;
        uint cd;
    }

    constructor (address _player1, address _player2, uint _bet, bool _isFull) {
        player1.name = _player1;
        player1.number = 1;
        player1.cd = 0;
        player1.move = "";
        player2.name = _player2;
        player2.number = 2;
        player2.cd = 0;
        player2.move = "";
        bet = _bet;
        isFull = _isFull;
    }
    
    uint timeBetweenPlays = 5 minutes;    //si el otro jugador no hizo la jugada => iniciar el cooldown
    Player player1;
    Player player2;
    uint bet;
    bool isFull;

    event playerMove(Player _payer, uint time);
    event moveReveal(Player _player1, Player _player2);
    event declareWinner(Player _winner);
    event playerTimeOut(Player _player);


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

    function declareMove(bytes32 _move) public isPlaying(msg.sender) {
        if (getPlayer()) {
            changeMove(_move, player1, player2);
        } else {
            changeMove(_move, player2, player1);
        }
    }

    function changeMove(bytes32 _move, Player _player, Player _rival) internal {
        _player.cd = now;
        require(_player.move == "", "you already made a move");
        if (_rival.cd != 0){
            if (_player.cd - _rival.cd > timeBetweenPlays) {
                emit playerTimeOut(_player);
                payWinner(_rival.number);
                return;
            }
        }
        _player.move = _move;
    }

    //ver el ganador y realizar el pago
    function revealMoves() public {

    }

}