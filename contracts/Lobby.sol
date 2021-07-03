// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// imports en remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Lobby is Ownable{

    using SafeMath for uint256;
 
    struct Game{
        address payable player1;
        address payable player2;
        uint bet;
        bool isFull;
        uint p1move;
        uint p2move;
    }
    constructor()  payable {
        
    }

    event gameCreated(Game _game);
    event gameJoined(Game _game);
    
    modifier isPlayer(Game memory _game){
        require (_game.player1 == msg.sender && _game.player2 == msg.sender);
        _;
    }
    
    Game[] games;
    
    function createGame(address payable _host,uint _bet) public{
        Game memory game = Game(_host,payable(address(0x0)),_bet,false, 0, 0);
        games.push(game);
        emit gameCreated(game);
    }
    
    function findGame(uint _minBet, uint _maxBet, address payable _searchingPlayer) public {
        for(uint i = 0; i < games.length; i++){
            if(games[i].isFull == false && games[i].bet > _minBet && games[i].bet < _maxBet){
                joinGame(games[i], _searchingPlayer);
                Game memory joinedGame = games[i];
                games[i] = games[games.length-1];
                delete games[games.length-1];
                //returns (address payable player1, address payable player2, uint bet, bool isFull) 
                // return (joinedGame.player1,joinedGame.player2,joinedGame.bet,joinedGame.isFull);
            }
        }
    }
    
    
   function joinGame(Game memory _game , address payable joinedPlayer) internal {
        _game.isFull = true;
        _game.player2 = joinedPlayer;
        emit gameJoined(_game);
    }
    
    function play(string memory _P1Move, string memory _P2Move, Game memory _game) public isPlayer(_game){
        
         uint p1HashedMove = hashMove(_P1Move);
         uint p2HashedMove = hashMove(_P2Move);
         
         require(p1HashedMove == uint(keccak256(abi.encodePacked(("rock")))) || p1HashedMove == uint(keccak256(abi.encodePacked(("paper")))) || p1HashedMove == uint(keccak256(abi.encodePacked(("scissors")))), 
         "The play must be 'rock', 'paper' or 'scissors' ");
         
         require(p2HashedMove == uint(keccak256(abi.encodePacked(("rock")))) || p2HashedMove == uint(keccak256(abi.encodePacked(("paper")))) || p2HashedMove == uint(keccak256(abi.encodePacked(("scissors")))), 
         "The play must be 'rock', 'paper' or 'scissors' ");
         
         payWiner(p1HashedMove,p2HashedMove,_game);
    }

//MATI: se tienen que crear de forma individual las movidas
    function declareMove(string memory _move, string memory _keyword, Game memory _game) public isPlayer(_game){
        uint keywordHash = uint(keccak256(abi.encodePacked(_keyword)));
        uint HashMove = hashMove(_move);
        uint codedMove = SafeMath.add(HashMove, keywordHash);
        if (isHost(msg.sender, _game)){
            _game.p1move = codedMove;
        } else {
            _game.p2move = codedMove;
        }

    }

    function isHost(address _player, Game memory _game) pure internal returns(bool) {
        return _player == _game.player1;
    }
    
     function hashMove(string memory _move) internal pure returns (uint hashedMove){
         uint  _hashedMove = uint(keccak256(abi.encodePacked(_move)));
         return (_hashedMove);
         
     }
     
     function checkWiner(uint _movePlayer1, uint _movePlayer2) internal pure returns (uint winer) {
         // keccak256 hash generator: https://sita.app/keccak256-hash-generator
         // rock:       hexa: 10977e4d68108d418408bc9310b60fc6d0a750c63ccef42cfb0ead23ab73d102  => uint: 7504671191028674570649298396935315689168425980718395638832996684551825903874
         // paper:      hexa: ea923ca2cdda6b54f4fb2bf6a063e5a59a6369ca4c4ae2c4ce02a147b3036a21  => uint: 106099584733913018769790338291824602800549410377166706717988945967699957344801
         // scissors:   hexa: 389a2d4e358d901bfdf22245f32b4b0a401cc16a4b92155a2ee5da98273dad9a  => uint: 25601926655740021617648276659444374542935864018550230109551161942298075180442
         
         uint rockUint  = 7504671191028674570649298396935315689168425980718395638832996684551825903874;
         uint paperUint = 106099584733913018769790338291824602800549410377166706717988945967699957344801;
         uint scissorsUint = 25601926655740021617648276659444374542935864018550230109551161942298075180442;
         
         //Tie
         if(_movePlayer1 == rockUint && _movePlayer2 == rockUint || _movePlayer1 == paperUint && _movePlayer2 == paperUint 
            || _movePlayer1 == scissorsUint && _movePlayer2 == scissorsUint){
             return (0); // its a tie
         }
         //Player 1 Wins
         if(_movePlayer1 == rockUint && _movePlayer2 == scissorsUint ||
            _movePlayer1 == paperUint && _movePlayer2 == rockUint ||
            _movePlayer1 == scissorsUint && _movePlayer2 == paperUint){
                
             return (1); //  player 1 Wins
             
         }else return(2);//  player 2 Wins
         
     }

//MATI: falto el caso en el que uno de los dos participantes no logro responder su jugada
    function checkWinerGame(Game memory _game) public returns (uint) {
        uint p1move = _game.p1move;
        uint p2move = _game.p2move;

        if (p1move == 0) {return (2);}
        if (p2move == 0) {return (1);}

        checkWiner(p1move, p2move);
    }
     
    
    function payWiner(uint  _movePlayer1, uint  _movePlayer2, Game memory _game) internal  {

         uint playerWiner = checkWiner(_movePlayer1,_movePlayer2);
         
         if(playerWiner == 0){
             _game.player1.transfer(_game.bet);
             _game.player2.transfer(_game.bet);
         }else if (playerWiner == 1){
             _game.player1.transfer(2*_game.bet);
         }else{ 
             _game.player2.transfer(2*_game.bet);
         }
         
     }
     
     
     function getGames() public view returns (Game[] memory){
        return games;
    }
}  

// no se bien como implementar esto 

//    function playMove(Game _game, string memory _move, string memory _keyword) public isPlayable(_move) {
//         string memory moveKeyword = _move + " " + _keyword;
//         bytes32 moveEncrypted =  keccak256(abi.encodePacked((moveKeyword)));
//         _game.playerMove[msg.sender] = moveEncrypted;
//         // hay que setear el timer
//     }