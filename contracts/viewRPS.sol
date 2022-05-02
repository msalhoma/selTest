// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./rockPaperScissors.sol";

/// @title View functions for - Rock, Paper, Scissors
/// @author Omar Msalha
contract ViewRPS is RockPaperScissors{

    /// @notice Views all currently open wages
    /// @return ids index of the wage in wages array
    /// @return openWages sum of wage in wei
    /// @dev indices in both arrays are tied together, i.e. one index belongs to one wage
    function viewOpenWages() external view returns(uint256[] memory, uint256[] memory) {

        uint256[] memory openWages = new uint256[](wages.length - closedWages);
        uint256[] memory ids = new uint256[](wages.length - closedWages);

        uint256 counter = 0;

        // find open wages
        for (uint i = 0; i < wages.length; i++) {
            if (wages[i].open == true) {
                openWages[counter] = wages[i].wage;
                ids[counter++] = i;
            }
        }

        return (ids, openWages);
    }

    /// @notice Views winner of _wageId wage
    /// @param _wageId index in wages array
    /// @return winner returns address of the winner in _wageId wage, if tie or not closed, address(0) is returned
    function viewWinner(uint256 _wageId) external view  isIdValid(_wageId) returns(address) {
        return winners[_wageId];
    }

    /// @notice Mainly for testing
    /// @return sum of all wages
    function getLength() external view returns(uint256){
        return wages.length;
    }
}
