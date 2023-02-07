pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

contract HalfCutToken is SafeERC20 {
  string public constant name = "HalfCut Token";
  string public constant symbol = "HCT";
  uint8 public constant decimals = 18;
  uint256 public totalSupply = 1000;
  uint256 public contractBalance = 0;

  mapping(address => uint256) public balances;
  mapping(address => mapping(address => uint256)) public referredStakes;

  constructor() public {
    balances[msg.sender] = totalSupply;
  }

  function transfer(address recipient, uint256 amount) public payable {
    require(balances[msg.sender] >= amount, "Insufficient balance.");

    uint256 taxAmount = amount / 2;
    uint256 transferAmount = amount - taxAmount;
    uint256 burnAmount = taxAmount / 2;
    uint256 contractAmount = taxAmount - burnAmount;

    balances[msg.sender] -= transferAmount;
    balances[recipient] += transferAmount;
    contractBalance += contractAmount;
    totalSupply -= burnAmount;
  }

  function stake(uint256 amount) public payable {
    require(balances[msg.sender] >= amount, "Insufficient balance.");

    uint256 taxAmount = amount / 4;
    uint256 stakeAmount = amount - taxAmount;

    balances[msg.sender] -= stakeAmount;
    referredStakes[msg.sender][msg.sender] += stakeAmount;
  }

  function unstake(uint256 amount) public payable {
    require(referredStakes[msg.sender][msg.sender] >= amount, "Insufficient stake.");

    referredStakes[msg.sender][msg.sender] -= amount;
    balances[msg.sender] += amount;
  }

  function airdrop(address recipient, uint256 amount) public payable {
    require(msg.sender == address(this), "Only contract owner can perform airdrop.");
    require(balances[address(this)] >= amount, "Insufficient balance in contract.");

    balances[address(this)] -= amount;
    balances[recipient] += amount;
  }

  function referralStake(address referrer, uint256 amount) public payable {
    require(balances[msg.sender] >= amount, "Insufficient balance.");

    uint256 taxAmount = amount / 4;
    uint256 stakeAmount = amount - taxAmount;
    uint256 referralAmount = stakeAmount * 3 / 100;

    balances[msg.sender] -= stakeAmount;
    referredStakes[referrer][msg.sender] += stakeAmount;
    if (referrer != address(0)) {
      balances[referrer] += referralAmount;
    } else {
      contractBalance += referralAmount
;
    }
  }

  function calculateStakeInterest() public payable {
    uint256 interest = 0;
    for (address user in referredStakes) {
      for (address referredUser in referredStakes[user]) {
        interest = referredStakes[user][referredUser] * 5 / 1000;
        referredStakes[user][referredUser] += interest;
        balances[referredUser] += interest;
      }
    }
  }

  function getBalance(address account) public view returns (uint256) {
    return balances[account];
  }
  
  function buy(uint256 _amount) public {
    require(dripToken.balanceOf(address(this)) >= _amount * price, "Not enough Drip Token");

    uint256 hctAmount = _amount / price;
    dripToken.transferFrom(address(this), msg.sender, _amount);
    dripToken.transfer(address(0x0), _amount * 0.1); // burn 10% of Drip Token received
    msg.sender.transfer(hctAmount);
  }
  
  function sell(uint256 _amount) public {
    require(balanceOf[msg.sender] >= _amount, "Not enough HalfCut Token");

    uint256 dripAmount = _amount * price;
    balanceOf[msg.sender] -= _amount;
    dripToken.transfer(msg.sender, dripAmount * 0.95); // keep 95% of the Drip Token received
    dripToken.transfer(address(0x0), dripAmount * 0.05); // burn 5% of the Drip Token received
  }
}
