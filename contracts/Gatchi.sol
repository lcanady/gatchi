// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/*
 * @ title Gatchi pet!
 * @ Author Lem Canady
 */

contract Gatchi is ERC1155, Ownable {
    using Strings for string;

    int256 constant hungerPerBlock = 1;
    int256 constant boredomPerBlock = 2;
    int256 constant energyPerBlock = 2;

    uint256 PRICE = 1000000000000000000;
    uint256 constant INCREASE = 500000000000000000;
    uint256 constant RATE = 20;
    uint256 constant MAX_GOTCHI = 1500;

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
        uint256 reward;
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

    /**
     * @notice Set the base URI of the gatchi
     * @param _URI The URI to set.
     */
    function setURI(string memory _URI) public onlyOwner {
        baseURI = _URI;
    }

    /**
     * @notice Set the price of the gatchi
     * @param _price The new price of the gatchi.
     */
    function setPrice(uint256 _price) public onlyOwner {
        PRICE = _price;
    }

    /**
     * @notice Get the current price of a Gatchi
     * @param _num The number of gatchi to mint!
     */
    function getPrice(uint256 _num) public view returns (uint256) {
        uint256 multiplier = (count + _num) / RATE;
        uint256 adjusted = INCREASE * multiplier;
        return PRICE + adjusted;
    }

    function mint(uint256 _amt) public payable {
        require(msg.value >= getPrice(_amt));
        require(count + _amt <= MAX_GOTCHI);

        uint256 i = 0;
        for (i = 0; i < _amt; i++) {
            _mint(msg.sender, count + 1, 1, "0x0");
        }
    }

    /**
     * @notice Create a new Gotchi!!
     * @param name_ The name of the new gotchi!
     * @param _address the address to become the gatchi owner!
     */
    function createGatchi(string memory name_, address _address) external {
        require(!gatchi[count].initiated);
        require(bytes(name_).length > 0);

        // Gatchi stats!
        gatchi[count].name = name_;
        gatchi[count].parent = _address;

        // Generate a random DNA number that will control the appearance of
        // some of the traits.
        gatchi[count].DNA = uint256(
            keccak256(abi.encodePacked(block.difficulty, count, bytes(name_)))
        );

        gatchi[count].initiated = true;

        // Set the rest pf the gatchi stats!
        gatchi[count].fed = 5000;
        gatchi[count].fedBlock = block.number;

        gatchi[count].entertained = 7000;
        gatchi[count].entertainedBlock = block.number;

        gatchi[count].rested = 90000;
        gatchi[count].restedBlock = block.number;

        gatchi[count].blockBorn = block.number;

        count += 1;
    }

    /**
     * @notice get information about an individual Gatchi!
     * @param _id the tokenid of the gatchi to get info for.
     */
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

    /**
     * @notice calculate the hunger accumulated since the last time the gatchi was fed.
     * @param _id the tokenid of the gatchi.
     */
    function calcHungerSince(uint256 _id) public view returns (int256 amount) {
        require(gatchi[_id].initiated);
        return hungerPerBlock * int256(block.number - gatchi[_id].fedBlock);
    }

    /**
     * @notice Calculate boredom since last entertained.
     * @param _id The tokenid of the gatchi.
     */
    function calcBoredomSince(uint256 _id) public view returns (int256 amount) {
        require(gatchi[_id].initiated);
        return
            boredomPerBlock *
            int256(block.number - gatchi[_id].entertainedBlock);
    }

    function calcEnergySince(uint256 _id) public view returns (int256 amount) {
        require(gatchi[_id].initiated);
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

    function uri(uint256 _id) public view override returns (string memory) {
        require(gatchi[_id].initiated, "NONEXISTANT_TOKEN");
        return
            string(abi.encodePacked(baseURI, Strings.toString(_id), ".json"));
    }
}
