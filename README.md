# Creating a DeFi Kingdom Clone on Avalanche 

Radiant Points ERC20 Token Contract:

This Solidity contract creates an ERC20 token named "radiant_points" with the symbol "v". It allows the initial supply to be minted to the deployer's address upon deployment, following the ERC20 standard for token functionalities such as transfer and balance checks.

Vault Contract:

This Solidity contract implements a vault system for an ERC20 token. Users can deposit and withdraw tokens, and manage their Omen, a user-specific structure. The contract allows Omen initialization, upgrades, and daily reward collection, ensuring secure and transparent token handling while tracking user balances and rewards.
## Description

Radiant Points ERC20 Token Contract:

This Solidity contract creates an ERC20 token named "radiant_points" with the symbol "v". The initial supply is minted to the deployer's address during deployment, following the ERC20 standard for functionalities like transfers and balance checks.

Vault Contract:

This Solidity contract implements a vault system for an ERC20 token. Users can deposit and withdraw tokens, and manage their Omen, a user-specific structure. The contract supports Omen initialization, upgrades, and daily reward collection, ensuring secure token handling and accurate tracking of user balances and rewards. This contract operates on a custom subnet created by the user, enhancing control and flexibility over the network environment.

## Getting Started

### Executing program

To run this program, you can use Remix, an online Solidity IDE. To get started, go to the Remix website at https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the "+" icon in the left-hand sidebar. Save the file with a .sol extension (e.g., myToken.sol). Copy and paste the following code into the file:

erc20.sol
```javascript
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract radiant_points is ERC20 {
    constructor(uint256 initialBalance) ERC20("radiant_points","v"){
        _mint(msg.sender, initialBalance);
    }
}
```
vault.sol
```javascript
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
```

To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler" option is set to "0.8.26" (or another compatible version), and then click on the "Compile degen.sol" button.

Once the code is compiled, you can tap on environment button and select "Injected Provider - MetaMask" then connect your metamask account to remix id.
After connecting the wallet deploy the contract by clicking on the "Deploy & Run Transactions" tab in the left-hand sidebar it will ask you to connect your metamask wallet for that , allow it. Select the "radiant_points" contract from the dropdown menu, and then click on the "Deploy" button.
After deploying copy the "radiant_points" contract address and during deploy of second contrct that is "vault", and paste that address and then click on deploy.

After deploying both contracts and linking it with each other we can interact with contract and use its different function.
## Authors

Saurabh Mishra  


## License

This project is licensed under the MIT License
