pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyMetaCoin is ERC20,ERC20Burnable, Ownable {

    uint256 totalSupply = 10000000;

    string tokeName = "My Meta Coin";
    string tokenSymbol = "MMC";

    address payable center; 

    constructor(address payable _center){
        center = _center;
    }

    constructor() ERC20("tokeName", "tokenSymbol"){
        _mint(center, totalSupply)
    }

    function mintReward(address center, uint256 amount) public onlyOwner{
        _mint(center, amount);
    }

    uint256 taxPercent = 5;
    uint256 percent_divider = 100;

    mapping(address => uint256) balance;

    function mint(address recipient) public onlyOwner
    {          
        _mint(recipient, totalSupply);            
    }

    function transfer(address from, address to, uint256 amount) public payable {

        uint256 tax = amount * taxpercent / percent_divider;
        uint256 buyAmount = amount + tax;
        balance[from] -= buyAmount;
        balance[to] += amount;
        balance[center] += tax;
    }

    function fundleasecost(address from, address to, uint256 amount){
        uint256 taxfrom = amount * taxpercent / percent_divider;
        uint256 taxto = amount * taxpercent / percent_divider;

        balance[from] -= (amount + taxfrom);
        balance[to] += (amount - taxto);
        balance[center] += (taxfrom + taxto);
    }

}

