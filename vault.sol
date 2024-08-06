// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {
    IERC20 public immutable token;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    struct Omen {
        uint level;
        string reward;
        uint upgradeCost;
        uint lastRewardTime;
    }

    mapping(address => Omen) private omens;

    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);
    event Upgrade(address indexed user, uint newLevel, uint newUpgradeCost);
    event RewardCollected(address indexed user, string reward, uint level);


    function deposit(uint _amount) external {
        require(_amount > 0, "Deposit amount must be greater than zero");

        token.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;

        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint _amount) external {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");

        token.transfer(msg.sender, _amount);
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;

        emit Withdraw(msg.sender, _amount);
    }

    function upgradeOmen() external {
        Omen storage omen = omens[msg.sender];
        require(omen.level > 0, "Omen not initialized");

        uint cost = omen.upgradeCost;
        require(balanceOf[msg.sender] >= cost, "Insufficient deposited tokens");

        balanceOf[msg.sender] -= cost;
        totalSupply -= cost;

        omen.level += 1;
        omen.upgradeCost = cost * 2;

        emit Upgrade(msg.sender, omen.level, omen.upgradeCost);
    }

    function getOmenInfo(address _owner) external view returns (uint level, string memory reward, uint upgradeCost) {
        Omen storage omen = omens[_owner];
        return (omen.level, omen.reward, omen.upgradeCost);
    }

    function dailyRewards() external {
        Omen storage omen = omens[msg.sender];
        require(omen.level > 0, "Omen not initialized");

        uint currentTime = block.timestamp;
        require(currentTime >= omen.lastRewardTime + 1 days, "Rewards can only be collected once a day");

        uint rewardAmount = omen.level * 2;

        balanceOf[msg.sender] += rewardAmount;
        totalSupply += rewardAmount;
        omen.lastRewardTime = currentTime;

        emit RewardCollected(msg.sender, omen.reward, omen.level);
    }

    function initializeOmen(string calldata _reward) external {
        Omen storage omen = omens[msg.sender];
        require(omen.level == 0, "Omen already initialized");
        omen.level = 1;
        omen.reward = _reward;
        omen.upgradeCost = 100;
    }
}
