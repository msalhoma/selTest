// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "hardhat/console.sol";

/// @title Test contract - Rock, Paper, Scissors
/// @author Omar Msalha
contract RockPaperScissors {
    
    // possible moves
    enum Move{ ROCK, PAPER, SCISSORS }

    struct Wage {
        address enroller; // owner of the wage
        address opponent;
        uint256 wage;
        Move enroller_move;
        Move opponent_move;
        bool open;
    }

    Wage[] wages;
    uint256 closedWages;

    mapping(uint256 => address) winners; // history of winners
    mapping(address => uint) internal balanceOf;

    uint8 public decimals = 18;
    uint public totalSupply;

    address owner;

    constructor() {
        closedWages = 0;
        owner = msg.sender;
    }

    event Enroll(address indexed enroller, uint wage);
    event Play(address indexed enroller, address indexed opponent, address indexed winner);
    event Cancel(address indexed enroller, uint id);

    modifier isIdValid(uint256 _id) {
        require(_id < wages.length, "Invalid ID.");
        _;
    }

    modifier enoughWei(uint256 _wage) {
        require(_wage <= balanceOf[msg.sender], "Not enough wei.");
        _;
    }

    /// @notice Create new wage
    /// @param _move the move enroller chose to wage on
    function enroll(Move _move, uint256 _wage) public enoughWei(_wage) {
        balanceOf[msg.sender] -= _wage;
        wages.push(Wage(msg.sender, address(0), _wage, _move, Move.ROCK, true));

        emit Enroll(msg.sender, _wage);
    }
    
    /// @notice Choose a wage to participate in and pick winner
    /// @param _wageId wage opponent chose, i.e. index in wages array
    /// @param _move the move opponent chose to wage on
    function play(uint256 _wageId, Move _move) public isIdValid(_wageId) enoughWei(wages[_wageId].wage){
        require(wages[_wageId].open == true, "Wage closed.");

        // close the wage first to avoid collision with cancelWage
        wages[_wageId].open = false;
        closedWages++;
        
        balanceOf[msg.sender] -= wages[_wageId].wage;

        // set opponent
        wages[_wageId].opponent = msg.sender;
        wages[_wageId].opponent_move = _move;

        _pickWinner(wages[_wageId], _wageId);
    }

    /// @notice Picks winner in a wage
    /// @param _id index in array of wages
    /// @param _wage struct of the wage
    function _pickWinner(Wage memory _wage, uint256 _id) private {
        Move enr_move = _wage.enroller_move;
        Move opp_move = _wage.opponent_move;

        if (enr_move == opp_move)
        {
            balanceOf[_wage.enroller] += _wage.wage;
            balanceOf[_wage.opponent] += _wage.wage;
            console.log("No winner.");
        }
        else if (enr_move == Move.ROCK && opp_move == Move.SCISSORS ||
            enr_move == Move.PAPER && opp_move == Move.ROCK ||
            enr_move == Move.SCISSORS && opp_move == Move.PAPER) 
        {
            balanceOf[_wage.enroller] += 2 * _wage.wage;
            winners[_id] = _wage.enroller;
            console.log("Enroller won.");
        }
        else
        {
            balanceOf[_wage.opponent] += 2 * _wage.wage;
            winners[_id] = _wage.opponent;
            console.log("Opponent won.");
        }

        emit Play(_wage.enroller, _wage.opponent, winners[_id]);
    }

    /// @notice Creates new wage
    /// @param _wageId index in wages array
    function cancelWage(uint256 _wageId) external isIdValid(_wageId) {
        require(payable(msg.sender) == wages[_wageId].enroller && wages[_wageId].open == true);
        // close the wage first to avoid collision with play
        wages[_wageId].open = false;
        closedWages++;
        // return wei back to wage owner
        balanceOf[msg.sender] += wages[_wageId].wage;

        emit Cancel(msg.sender, _wageId);
    }

}
