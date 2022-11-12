pragma solidity 0.8.4;

contract MMRefferral {

	using SafeMath for uint256;

	receive() external payable {}

	uint constant public PERCENTS_DIVIDER = 100;
	uint public REFERRAL_PERCENTS	= 50;

	uint public TOTAL_REFDIVIDENDS;
	uint public TOTAL_REFDIVIDENDS_CLAIMED;

	struct TUser {
		uint	refCount;
		address referrer;
		uint dividends;
		uint refDividends;
	}

	mapping( address => TUser ) public	USERS;

	constructor( ) { }

	function setReferer(address _referrer) public payable {
        _setUserReferrer(msg.sender, _referrer);
        _allocateReferralRewards(msg.sender, msg.value);
	}

	function _setUserReferrer(address _user, address _referrer) internal {

		if (USERS[_user].referrer != address(0)) return;	//already has a referrer
		if (_user == _referrer) return;						//cant refer to yourself

		//adopt
		USERS[_user].referrer = _referrer;

		//loop through the referrer hierarchy, increase every referral Levels counter
		address upline = USERS[_user].referrer;
		if(upline!=address(0)) {
			USERS[upline].refCount++;
		}

	}

	function _allocateReferralRewards(address _user, uint _amount) internal {

		//loop through the referrer hierarchy, allocate refDividends
		address upline = USERS[_user].referrer;
		if (upline != address(0)) {
			uint amount = _amount * REFERRAL_PERCENTS / PERCENTS_DIVIDER;
			USERS[upline].refDividends += amount;
			USERS[_user].dividends -= amount;
			TOTAL_REFDIVIDENDS += amount;
		}
	}
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
