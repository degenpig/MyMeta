pragma solidity 0.8.4;

contract MMCharity {
    address payable donator;
    address payable center;
    uint256 totalDonationsAmount;

    uint256 taxPercent = 20;
    uint256 percent_divider = 100;
    
    mapping(address => uint256) balance;

    constructor(address payable _center){
        center = _center;
    }

    modifier validateTransferAmount() {
        require(msg.value > 0, 'Transfer amount has to be greater than 0.');
        _;
    }

    function donateTransfer(address _from, address _to, amount){
        public uint256 tax = amount * taxPercent / percent_divider;
        uint256 donateAmount = amount + tax;
        balance[from] -= donateAmount;
        balance[to] += amount;
        balance[center] += tax;
    }

    function destroy() public restrictDonator() {
        selfdestruct(donator);
    }
}