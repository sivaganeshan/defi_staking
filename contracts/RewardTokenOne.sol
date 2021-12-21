pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardTokenOne is ERC20{

    address public admin;

    constructor(uint256 _supply) ERC20("RewardTokenOne", "RONE"){
        admin = msg.sender;
        _mint(msg.sender, _supply * (10 ** decimals()));
    }

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
             "Only admin allowed to Execute this function"
             );
        _;
    }


    function mint(address to, uint amount) onlyAdmin external {
        require(amount< 10001 * 10 **18, "Can only mint token upto 10001 tokens");
        _mint(to, amount);
    }

    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }

}