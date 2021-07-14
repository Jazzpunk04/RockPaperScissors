// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "contracts/GameRoom.sol";

// imports en remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Lobby is Ownable{

    using SafeMath for uint;
 
    mapping (address => GameRoom) gameRooms;

    constructor()  payable {
        
    }

    event gameCreated(GameRoom _game);                          /** o es asi event gameCreated(address _game);  ??*/
    event gameJoined(GameRoom _game, address _joinedPlayer);    /** o es asi event event gameJoined(address _game, address _joinedPlayer);  ??*/
    
    
    function createGame(address payable _host,uint _bet) public{
        require(_host.balance > _bet, "you don't have the required balance to create the game");
        GameRoom game = new GameRoom(_host,_bet);
        gameRooms[address(game)] = game;
        emit gameCreated(game);
    }
    
    
   function joinGame(address _gamegameRoomAdress , address payable _joinedPlayer) internal {
        GameRoom game = gameRooms[_gamegameRoomAdress];
        game.setPlayer2(_joinedPlayer);
        emit gameJoined(game, _joinedPlayer);
    }
}  

// no se bien como implementar esto 

//    function playMove(Game _game, string memory _move, string memory _keyword) public isPlayable(_move) {
//         string memory moveKeyword = _move + " " + _keyword;
//         bytes32 moveEncrypted =  keccak256(abi.encodePacked((moveKeyword)));
//         _game.playerMove[msg.sender] = moveEncrypted;
//         // hay que setear el timer
//     }