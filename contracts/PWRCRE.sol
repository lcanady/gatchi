// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/*
 * @title PWRCRE!!
 * @Author Lem Canady
 */

contract PWRCRE is ERC1155, Ownable {
    using Strings for string;

    uint256 constant TOTAL_CORES = 5000;
    uint256 constant RATE = 1000000000000000000;
    uint256 constant PER = 10;

    string _name;
    string _symbol;
    string _baseURI;
    uint256 count;

    mapping(uint256 => address) coreToAddress;
    uint256 price = 30000000000000000000;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) ERC1155(uri_) {
        _name = name_;
        _symbol = symbol_;
        _baseURI = uri_;
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
     * @notice Get the current count.
     */
    function getCount() public view returns (uint256) {
        return count;
    }

    /**
     * @notice get a semi-random number!
     * @param _seed A seed to help randomize the number.
     */
    function rand(uint256 _seed) public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(_seed, block.difficulty, block.timestamp)
                )
            ) % count;
    }

    /**
     * @notice Mint a PWRCRE!
     * @param _amt The numver of cores to mint.
     */
    function mint(uint256 _amt) public payable {
        require(msg.value >= getPrice(_amt), "Not enough Matic to mint.");
        require(count + _amt <= TOTAL_CORES, "No more cores to mint!");

        // Take 10% of the PWRCRE sale and send it to a random
        // address every mint.  Make sure this isn't the first purchase first
        if (count > 0) {
            payable(coreToAddress[rand(count)]).transfer(msg.value / 10);
        }

        // Mint the total number of PWRCRES.
        uint256 i;
        for (i = 0; i < _amt; i++) {
            _mint(msg.sender, count + i, 1, "0x0");
        }

        // increase the number of PWRCRES minted.
        count += _amt;
    }

    /**
     * @notice Make sure the new owner gets the benefits of the lottery!
     */
    function _beforeTokenTransfer(
        address,
        address,
        address to,
        uint256[] memory ids,
        uint256[] memory,
        bytes memory
    ) internal virtual override {
        uint256 i;
        for (i = 0; i < ids.length; i++) {
            coreToAddress[ids[i]] = to;
        }
    }

    /**
     * @notice get the token URI.
     */
    function uri(uint256) public view override returns (string memory) {
        return _baseURI;
    }

    /**
     * @notice withdrawl the funds from the contract.
     */
    function withdrawl() public payable onlyOwner {
        require(address(this).balance > 0, "Nothing to withdrawl!");
        uint256 payout = address(this).balance / 10;
        uint256 share = payout / count;

        // Airdrop the shares!
        uint256 i;
        for (i = 0; i < count; i++) {
            payable(coreToAddress[i]).transfer(share);
        }

        // Send the rest to the contract owner.
        payable(owner()).transfer(address(this).balance);
    }
}
