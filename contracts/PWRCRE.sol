// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/*
 * @title PWRCRE!!
 * @Author Lem Canady
 */

contract Gatchi is ERC1155, Ownable {
    using Strings for string;

    uint256 constant TOTAL_CORES = 5000;
    uint256 constant RATE = 1000000000000000000;
    uint256 constant PER = 20;

    string _name;
    string _symbol;
    string _baseURI;
    uint256 count;
    address[] list;
    uint256 price = 20000000000000000000;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory _uri
    ) ERC1155(_uri) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @notice Get the name of the contract.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @notice Get the Symbol of the contract.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Set hte URI of the metadata.
     * @param _uri The uri to set.
     */
    function setURI(string memory _uri) public onlyOwner {
        _baseURI = _uri;
    }

    /**
     * @notice Set the base price.
     * @param _price The base price to set.
     */
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    /**
     * @notice Get the current price of a Gatchi
     * @param _num The number of gatchi to mint!
     */
    function getPrice(uint256 _num) public view returns (uint256) {
        uint256 multiplier;
        uint256 adjusted;
        uint256 ret;

        uint256 i = 0;
        for (i = 0; i < _num; i++) {
            multiplier = (count + i) / PER;
            adjusted = RATE * multiplier;
            ret += price + adjusted;
        }

        return ret;
    }

    /**
     * @notice get a semi-random number!
     * @param _seed A seed to help randomize the number.
     */
    function rand(uint256 _seed) private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        _seed,
                        block.difficulty,
                        block.timestamp,
                        list.length
                    )
                )
            ) % list.length;
    }

    /**
     * @notice Mint a PWRCRE!
     * @param _amt The numver of cores to mint.
     */
    function mint(uint256 _amt) public payable {
        require(msg.value >= getPrice(_amt));
        require(count + _amt <= TOTAL_CORES);

        // Take 10% of the PWRCRE sale and send it to a random
        // address every mint.
        payable(list[rand(count)]).transfer(msg.value / 10);

        // Mint the total number of PWRCRES.
        uint256 i = 0;
        for (i = 0; i < _amt; i++) {
            _mint(msg.sender, count + 1, 1, "0x0");
        }

        // If this is the last mint, airdrop 10% of the contract
        // balance with all current PWRCRE holders.
        if (count + _amt == TOTAL_CORES) {
            uint256 payout = address(this).balance / 10;
            uint256 share = payout / list.length;

            for (i = 0; i < list.length; i++) {
                payable(list[i]).transfer(share);
            }
        }

        // increase the number of PWRCRES minted.
        count += _amt;
    }

    /**
     * @notice get the token URI.
     */
    function uri() public view returns (string memory) {
        return _baseURI;
    }
}
