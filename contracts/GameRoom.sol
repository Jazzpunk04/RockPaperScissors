// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


// imports en remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract GameRoom {
    using SafeMath for uint;

    
    address payable player1;
    address payable player2;
    uint bet;
    bool isFull;
    mapping (address => bytes32) moves;
    mapping (address => uint) cooldowns;
    mapping (address => uint) selection; //tijeras => 0; papel => 1; piedra => 2
    uint timeBetweenPlays = 5 minutes;
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
    
    constructor  (address payable _player1, uint _bet) payable { 
        player1 = _player1;
        bet = _bet;
        isFull = false;
        isOpen = true;
    }
    
    function setPlayer2(address payable _player2) external payable{
        require(_player2.balance >= bet); 
        player2 = _player2;
        isFull = true;
    }

    function declareMove(bytes32 _move) public isPlayer() {
        require(isOpen, "the game is already over, thanks for playing!");
        if (getPlayer() == 1) {
            changeMove(_move, player1, player2);
        } else {
            changeMove(_move, player2, player1);
        }
    }

    function changeMove(bytes32 _move, address payable _player, address payable _rival) internal {
        uint cooldown = block.timestamp;
        cooldowns[_player] = cooldown;
        require(moves[_player] == "", "you already made a move"); //VER COMO ARREGLARLO
        if (cooldowns[_rival] != 0){
            if (cooldowns[_player] - cooldowns[_rival] > timeBetweenPlays) {
                emit playerTimeOut(_player);
                //payWinner(_rival.number); FALTA HACER
                _rival.transfer(bet*2);
                isOpen = false;
                return;
            }
        }
        bytes32 move = _move;
        move = moves[_player];
        emit playerMove(_player, cooldown);
    }
    
    function revealMove(string memory _move, bytes32 _commitedMove) public isPlayer() {
        require(_commitedMove == keccak256(abi.encodePacked(_move)), "the moves are not the same");
        bytes memory moveInBytes = bytes(_move);
        if (moveInBytes[0] == 't'){
            uint moveNumber = 0;
            moveNumber = selection[msg.sender];        
        }
        if (moveInBytes[0] == 'p'){
            if (moveInBytes[1] == 'a') {
                uint moveNumber = 1;
                selection[msg.sender] = moveNumber;    
            } else if (moveInBytes[1] == 'i') {
                uint moveNumber = 2;
                selection[msg.sender] = moveNumber;        
            }
        }   
    }

    function getPlayer() internal view returns(uint) {
        if (msg.sender == player1){
            return 1;
        }else{
        return 2;
        }
    }

    function declareWinner() public { //MATI tengo que ver como hacer para  verificar que ambos jugadores revelaron sus jugadas
        require(isOpen, "the game is already over, thanks for playing!");
        uint choice1 = selection[player1];
        uint choice2 = selection[player2];
        
        if (choice1 == 0) {
            if (choice2 == 0) {
                player1.transfer(bet);
                player2.transfer(bet);
                emit emitDraw();
            }
            else if (choice2 == 1) {
                player1.transfer(bet*2);
                emit emitWinner(player1);
            }
            else if (choice2 == 2) {
                player2.transfer(bet*2);
                emit emitWinner(player2);
            }
        }
        else if (choice1 == 1) {
            if (choice2 == 0) {
                player2.transfer(bet*2);
                emit emitWinner(player2);}
            else if (choice2 == 1) {
                player1.transfer(bet);
                player2.transfer(bet);
                emit emitDraw();
            }
            else if (choice2 == 2) {
                player1.transfer(bet*2);
                emit emitWinner(player1);
            }
        }
        else if (choice1 == 2) {
            if (choice2 == 0) {
                player1.transfer(bet*2);
                emit emitWinner(player1);
            }
            else if (choice2 == 1) {
                player2.transfer(bet*2);
                emit emitWinner(player2);}
            else if (choice2 == 2) {
                player1.transfer(bet);
                player2.transfer(bet);
                emit emitDraw();
            }
        }
        isOpen = false;
    }

//    function play(string memory _P1Move, string memory _P2Move) public isPlayer(){
       
//          uint p1HashedMove = hashMove(_P1Move);
//          uint p2HashedMove = hashMove(_P2Move);
         
//          require(p1HashedMove == uint(keccak256(abi.encodePacked(("rock")))) 
//          || p1HashedMove == uint(keccak256(abi.encodePacked(("paper")))) 
//          || p1HashedMove == uint(keccak256(abi.encodePacked(("scissors")))), 
//          "The play must be 'rock', 'paper' or 'scissors' ");
         
//          require(p2HashedMove == uint(keccak256(abi.encodePacked(("rock")))) || 
//          p2HashedMove == uint(keccak256(abi.encodePacked(("paper")))) || 
//          p2HashedMove == uint(keccak256(abi.encodePacked(("scissors")))), 
//          "The play must be 'rock', 'paper' or 'scissors' ");
         
//          payWiner(p1HashedMove,p2HashedMove);
//     }
//      function hashMove(string memory _move) internal pure returns (uint hashedMove){
//          uint  _hashedMove = uint(keccak256(abi.encodePacked(_move)));
//          return (_hashedMove);
         
//      }
     
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
         
    function payWiner(uint  _movePlayer1, uint  _movePlayer2) internal  {

         uint playerWiner = checkWiner(_movePlayer1,_movePlayer2);
         
         if(playerWiner == 0){
             player1.transfer(bet);
             player2.transfer(bet);
         }else if (playerWiner == 1){
             player1.transfer(2*bet);
         }else{ 
             player2.transfer(2*bet);
         }
         
     }
    

}
    //MATI: se tienen que crear de forma individual las movidas
    // function declareMove(string memory _move, string memory _keyword) public  isPlayer(){
    //     if (msg.sender == player1){
    //         require(player1Move == 0, "you already made a move");
    //         player1Move = setCodedMove(_move,_keyword);
    //     } else {
    //         require(player2Move == 0);
    //         player2Move = setCodedMove(_move,_keyword);
    //     }

    // }
    
    // function setCodedMove(string memory _move, string memory _keyword)internal view returns (uint _codedMove){
    //     uint keywordHash = uint(keccak256(abi.encodePacked(_keyword)));
    //     uint HashMove = hashMove(_move);
    //     uint codedMove = SafeMath.add(HashMove, keywordHash);
    //     return codedMove;
    // }
// struct Player {
    //     uint number;
    //     address name;
    //     byte32 move;
    //     uint cd;
    // }

    // constructor (address _player1, address _player2, uint _bet, bool _isFull) {
    //     player1.name = _player1;
    //     player1.number = 1;
    //     player1.cd = 0;
    //     player1.move = "";
    //     player2.name = _player2;
    //     player2.number = 2;
    //     player2.cd = 0;
    //     player2.move = "";
    //     bet = _bet;
    //     isFull = _isFull;
    // }
    
    // uint timeBetweenPlays = 5 minutes;    //si el otro jugador no hizo la jugada => iniciar el cooldown
    // Player player1;
    // Player player2;
    // uint bet;
    // bool isFull;




    // modifier isPlaying(address _address){
    //     require(_address == player1.name || _address == player2.name);
    //     _;
    // }

    // modifier isTheHost(address _address){
    //     require(_address == player1.name);
    //     _;
    // }

 

    


    // //ver el ganador y realizar el pago
    // function revealMoves() public {

    // }

    // function payWiner(uint _winner) public {

    // }