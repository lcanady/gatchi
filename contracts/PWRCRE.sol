// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/*
 * @ title Gatchi pet!
 * @ Author Lem Canady
 */

contract Gatchi is ERC1155, Ownable {
    using Strings for string;

    uint256 constant TOTAL_CORES = 5000;
    uint256 constant RATE = 1000000000000000000;

    string _name;
    string _symbol;
    string _baseURI;
    uint256 count;
    uint256 price = 20000000000000000000;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory _uri
    ) ERC1155(_uri) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function setURI(string memory _uri) public {
        _baseURI = _uri;
    }

    /**
     * @notice Get the current price of a Gatchi
     * @param _num The number of gatchi to mint!
     */
    function getPrice(uint256 _num) public view returns (uint256) {
        uint256 multiplier = (count + _num) / RATE;
        uint256 adjusted = RATE * multiplier;
        return price + adjusted;
    }

    /**
     * @notice Mint a PWRCRE!
     * @param _amt The numver of cores to mint.
     */
    function mint(uint256 _amt) public payable {
        require(msg.value >= getPrice(_amt));
        require(count + _amt <= TOTAL_CORES);

        uint256 i = 0;
        for (i = 0; i < _amt; i++) {
            _mint(msg.sender, count + 1, 1, "0x0");
        }
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(_baseURI, Strings.toString(tokenId), ".json")
            );
    }
}
