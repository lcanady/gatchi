// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/*
 * @ title Gatchi pet!
 * @ Author Lem Canady
 */

contract Gatchi is ERC1155 {
    int256 constant hungerPerBlock = 1;
    int256 constant boredomPerBlock = 2;
    int256 constant energyPerBlock = 2;

    int256 constant hungerPerFeed = 4000;
    int256 constant boredomPerEntertainment = 2000;
    int256 constant energyPerSleep = 8000;

    string baseURI;
    string _name;
    string _symbol;

    uint256 count = 0;

    struct GatchiStruct {
        string name;
        address parent;
        uint256 DNA;
        uint256 attack;
        uint256 defense;
        uint256 reward;
        int256 stage;
        int256 fed;
        uint256 fedBlock;
        int256 entertained;
        uint256 entertainedBlock;
        int256 rested;
        uint256 restedBlock;
        uint256 blockBorn;
        bool initiated;
    }

    mapping(uint256 => GatchiStruct) public gatchi;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory _URI
    ) ERC1155(_URI) {
        baseURI = _URI;
        _name = name_;
        _symbol = symbol_;
    }

    function createGatchi(string memory name_, address _address) external {
        require(!gatchi[count].initiated);
        require(bytes(name_).length > 0);

        gatchi[count].name = name_;
        gatchi[count].parent = _address;
        gatchi[count].DNA = uint256(
            keccak256(abi.encodePacked(block.difficulty, count, bytes(name_)))
        );
        gatchi[count].stage = 0;
        gatchi[count].attack = 0;

        gatchi[count].initiated = true;

        gatchi[count].fed = 5000;
        gatchi[count].fedBlock = block.number;

        gatchi[count].entertained = 7000;
        gatchi[count].entertainedBlock = block.number;

        gatchi[count].rested = 90000;
        gatchi[count].restedBlock = block.number;

        gatchi[count].blockBorn = block.number;

        count += 1;
    }

    function getGatchi(uint256 _id)
        public
        view
        returns (
            string memory gatchiName,
            int256 fed,
            int256 entertained,
            int256 rested,
            uint256 age,
            bool isDead
        )
    {
        require(gatchi[_id].initiated);
        return (
            gatchi[_id].name,
            gatchi[_id].fed - calcHungerSince(_id),
            gatchi[_id].entertained - calcBoredomSince(_id),
            gatchi[_id].rested - calcEnergySince(_id),
            block.number - gatchi[_id].blockBorn,
            hasgGatchiDied(_id)
        );
    }

    function calcHungerSince(uint256 _id) public view returns (int256 amount) {
        return hungerPerBlock * int256(block.number - gatchi[_id].fedBlock);
    }

    function calcBoredomSince(uint256 _id) public view returns (int256 amount) {
        return
            boredomPerBlock *
            int256(block.number - gatchi[_id].entertainedBlock);
    }

    function calcEnergySince(uint256 _id) public view returns (int256 amount) {
        return energyPerBlock * int256(block.number - gatchi[_id].restedBlock);
    }

    function hasgGatchiDied(uint256 _id) public view returns (bool isDead) {
        require(gatchi[_id].initiated);

        int256 fed = gatchi[_id].fed - calcHungerSince(_id);
        int256 entertained = gatchi[_id].entertained - calcBoredomSince(_id);
        int256 rested = gatchi[_id].rested - calcEnergySince(_id);

        if ((fed <= 0) || (entertained <= 0) || (rested <= 0)) {
            return true;
        } else {
            return false;
        }
    }

    function feed(uint256 _id) external {
        require(gatchi[_id].initiated);
        require(!hasgGatchiDied(_id));

        gatchi[_id].fed =
            hungerPerFeed +
            gatchi[_id].fed -
            calcHungerSince(_id);
        gatchi[_id].fedBlock = block.number;
    }

    function play(uint256 _id) external {
        require(gatchi[_id].initiated);
        require(!hasgGatchiDied(_id));

        gatchi[_id].entertained =
            boredomPerEntertainment +
            gatchi[_id].entertained -
            calcBoredomSince(_id);
        gatchi[_id].entertainedBlock = block.number;
    }

    function sleep(uint256 _id) external {
        require(gatchi[_id].initiated);
        require(!hasgGatchiDied(_id));

        gatchi[_id].rested =
            energyPerSleep +
            gatchi[_id].rested -
            calcEnergySince(_id);
        gatchi[_id].restedBlock = block.number;
    }
}
