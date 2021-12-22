pragma solidity ^0.8.0;

import "./RewardTokenOne.sol";

contract TokenFarming {
    string public name = "StakingDemoRinkeby";
    uint256 public ethRewardPerToken = 4;
    uint256 public roneRewardPerToken = 10;
    uint256 public minimumEthToStake = 0.1 ether;
    uint256 public minimumRoneToStake = 100 ether;

    address public admin;
    RewardTokenOne public _rewardTokenOne;
    address[] public stakers;

    uint256 public balanceOfEthStaked;
    uint256 public balanceOfRoneStaked;

    struct User {
        bool isStaked;
        uint256 ethStaked;
        uint256 roneStaked;
        uint256 ethRewardsAccumulated;
        uint256 ethRewardsWithdrawn;
        uint256 roneRewardsAccumulated;
        uint256 roneRewardsWithdrawn;
        uint256 lastUpdateDate;
    }

    mapping(address => User) userDetails;

    // Contract's Events
    event Stake(address indexed sender, uint256 amount, string token);
    event Unstake(address indexed sender, uint256 amount, string token);

    constructor(RewardTokenOne rewardTokenOne) {
        _rewardTokenOne = rewardTokenOne;
        admin = msg.sender;
    }

    function StakeEth() public payable {
        require(
            msg.value > minimumEthToStake,
            "Requireed minimmum 0.1 Eth to stake"
        );
        if (userDetails[msg.sender].isStaked == false) {
            userDetails[msg.sender] = User(
                true,
                msg.value,
                0,
                0,
                0,
                0,
                0,
                block.timestamp
            );
            stakers.push(msg.sender);
            balanceOfEthStaked = balanceOfEthStaked + msg.value;
        } else {
            userDetails[msg.sender].ethStaked =
                userDetails[msg.sender].ethStaked +
                msg.value;
            userDetails[msg.sender].isStaked = true;
            balanceOfEthStaked = balanceOfEthStaked + msg.value;
        }
        emit Stake(msg.sender, msg.value, "ETH staked");
    }

    function StakeRone(uint256 _amount) public {
        require(
            _amount > minimumRoneToStake,
            "Requireed minimmum 100 RONE to stake"
        );
        if (userDetails[msg.sender].isStaked == false) {
            //Transfer Rone token to this contract for staking
            _rewardTokenOne.transferFrom(msg.sender, address(this), _amount);
            userDetails[msg.sender] = User(
                true,
                0,
                _amount,
                0,
                0,
                0,
                0,
                block.timestamp
            );
            userDetails[msg.sender].isStaked = true;
            stakers.push(msg.sender);
            balanceOfRoneStaked = balanceOfRoneStaked + _amount;
        } else {
            _rewardTokenOne.transferFrom(msg.sender, address(this), _amount);
            userDetails[msg.sender].roneStaked =
                userDetails[msg.sender].roneStaked +
                _amount;
            userDetails[msg.sender].isStaked = true;
            balanceOfRoneStaked = balanceOfRoneStaked + _amount;
        }
        emit Stake(msg.sender, _amount, "Rone Staked");
    }

    function unstakeEth() public {
        require(
            userDetails[msg.sender].isStaked == true,
            "user haven't staked Eth with us !!!"
        );
        require(
            userDetails[msg.sender].ethStaked > 0,
            "user haven't staked Eth with us !!!"
        );

        // Transfer balance back to the user
        (bool sent, ) = msg.sender.call{
            value: userDetails[msg.sender].ethStaked
        }("");
        require(sent, "Failed to send user balance back to the user");
        uint256 unStakingAmount = userDetails[msg.sender].ethStaked;
        userDetails[msg.sender].ethStaked = 0;
        if (!(userDetails[msg.sender].roneStaked > 0)) {
            userDetails[msg.sender].isStaked = false;
        }
        balanceOfEthStaked = balanceOfEthStaked - unStakingAmount;
        emit Unstake(msg.sender, unStakingAmount, "Eth UnStaked");
    }

    function unStakeRone() public {
        require(
            userDetails[msg.sender].isStaked == true,
            "user haven't staked Eth with us !!!"
        );
        require(
            userDetails[msg.sender].roneStaked > 0,
            "user haven't staked Eth with us !!!"
        );

        //if valid transfer from smart contract to sender
        _rewardTokenOne.transfer(
            msg.sender,
            userDetails[msg.sender].roneStaked
        );
        uint256 unStakingAmount = userDetails[msg.sender].roneStaked;
        userDetails[msg.sender].roneStaked = 0;
        if (!(userDetails[msg.sender].ethStaked > 0)) {
            userDetails[msg.sender].isStaked = false;
        }
        balanceOfRoneStaked = balanceOfRoneStaked - unStakingAmount;
        emit Unstake(msg.sender, unStakingAmount, "Rone UnStaked");
    }

    function isUserStaked() public view returns (bool) {
        return userDetails[msg.sender].isStaked;
    }

    function getEthRewardsAccumulated() public view returns (uint256) {
        return userDetails[msg.sender].ethRewardsAccumulated;
    }

    function getEthRewardsWithdrawn() public view returns (uint256) {
        return userDetails[msg.sender].ethRewardsWithdrawn;
    }

    function getRoneRewardsAccumulated() public view returns (uint256) {
        return userDetails[msg.sender].roneRewardsAccumulated;
    }

    function getRoneRewardsWithdrawn() public view returns (uint256) {
        return userDetails[msg.sender].roneRewardsWithdrawn;
    }

    function calculateAndDistributeRewards() public {
        require(msg.sender == admin, "only admins can distribute awards");

        for (uint256 i = 0; i < stakers.length; i++) {
            if (
                (block.timestamp - userDetails[stakers[i]].lastUpdateDate) /
                    86400 >
                1
            ) {
                if (userDetails[stakers[i]].ethStaked > 0) {
                    uint256 currentEthReward = ((userDetails[stakers[i]]
                        .ethStaked *
                        ethRewardPerToken *
                        (block.timestamp -
                            userDetails[stakers[i]].lastUpdateDate)) /
                        31556926);
                    userDetails[stakers[i]].ethRewardsAccumulated =
                        userDetails[stakers[i]].ethRewardsAccumulated +
                        currentEthReward;
                }

                if (userDetails[stakers[i]].roneStaked > 0) {
                    uint256 currentRoneReward = ((userDetails[stakers[i]]
                        .roneStaked *
                        ethRewardPerToken *
                        (block.timestamp -
                            userDetails[stakers[i]].lastUpdateDate)) /
                        31556926);
                    userDetails[stakers[i]].roneRewardsAccumulated =
                        userDetails[stakers[i]].roneRewardsAccumulated +
                        currentRoneReward;
                }

                userDetails[stakers[i]].lastUpdateDate = block.timestamp;
            }
        }
    }

    function collectEthRewards() public {
        require(
            userDetails[msg.sender].isStaked == true,
            "you should have staked eth/rone to calculate rewards"
        );
        uint256 rewardsToWithdraw = (userDetails[msg.sender]
            .ethRewardsAccumulated -
            userDetails[msg.sender].ethRewardsWithdrawn);
        require(rewardsToWithdraw > 0, "No rewards to collect");

        _rewardTokenOne.transfer(msg.sender, rewardsToWithdraw);
        userDetails[msg.sender].ethRewardsWithdrawn =
            userDetails[msg.sender].ethRewardsWithdrawn +
            rewardsToWithdraw;
    }

    function collectRoneRewards() public {
        require(
            userDetails[msg.sender].isStaked == true,
            "you should have staked eth/rone to calculate rewards"
        );
        uint256 rewardsToWithdraw = (userDetails[msg.sender]
            .roneRewardsAccumulated -
            userDetails[msg.sender].roneRewardsWithdrawn);
        require(rewardsToWithdraw > 0, "No rewards to collect");

        _rewardTokenOne.transfer(msg.sender, rewardsToWithdraw);
        userDetails[msg.sender].roneRewardsWithdrawn =
            userDetails[msg.sender].roneRewardsWithdrawn +
            rewardsToWithdraw;
    }
}
