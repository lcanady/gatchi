// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/*
 * @title Gatchi pet!
 * @Author Lem Canady
 */

contract GatchiLte is ERC1155, Ownable {
    using Strings for string;

    uint256 constant RATE = 86400;
    uint256 constant STAGES = 3;
    uint256 TOTAL_GATCHI = 5000;

    string _name;
    string _symbol;
    string _baseURI;

    struct GachiLite {
        uint256 stage;
        uint256 bornOn;
        uint256 variant;
        bool initiated;
    }

    mapping(uint256 => GachiLite) gatchi;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory _uri
    ) ERC1155(_uri) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @notice Get the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @notice Get the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Set the baseURI
     */
    function setURI(string memory _uri) public {
        _baseURI = _uri;
    }

    function getStage(uint256 _id) public view returns (uint256) {
        uint256 stage = gatchi[_id].bornOn / RATE;

        if (stage <= STAGES) {
            return stage;
        }

        return STAGES;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _baseURI,
                    Strings.toString(getStage(tokenId)),
                    "/",
                    Strings.toString(tokenId),
                    ".json"
                )
            );
    }
}
