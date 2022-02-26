// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface Gotchi {
    function createGatchi(string memory name_, address _address) external;

    function getGatchi(uint256 _id)
        external
        view
        returns (
            string memory gatchiName,
            int256 fed,
            int256 entertained,
            int256 rested,
            uint256 age,
            bool isDead
        );

    function calcHungerSince(uint256 _id) external view returns (int256 amount);

    function calcBoredomSince(uint256 _id)
        external
        view
        returns (int256 amount);

    function calcEnergySince(uint256 _id) external view returns (int256 amount);

    function hasgGatchiDied(uint256 _id) external view returns (bool isDead);
}
