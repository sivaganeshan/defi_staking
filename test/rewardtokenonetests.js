const {expect} = require('chai');
const { ethers , waffle} = require("hardhat");
const provider = waffle.provider;
const BigNumber = require('big-number');

function tokens(n){
    return ethers.utils.parseEther(n);
}

function format(n){
    return ethers.utils.formatEther(n);
}

describe("Token farming tests", async()=>{

    let rewardToken;
    let tokenFarming;
    let owner;
    let investor1;
    let investor2;
    let investor3;
    let totalSupply = 100000000;

    beforeEach(async function () {

        // Get the ContractFactory and Signers here.
        [owner, investor1, investor2, ...investor3] = await ethers.getSigners();
        console.log("all adresses", owner.address,investor1.address,investor2.address);
        const rewardTokenOne = await ethers.getContractFactory("RewardTokenOne");
        //Deploy smartcontract with the constrctor parameter
        rewardToken = await rewardTokenOne.deploy(totalSupply); 
        //Deploy smartcontract with the constrctor parameter
        const tokenFarmingContract = await ethers.getContractFactory("TokenFarming");
        tokenFarming = await tokenFarmingContract.deploy(rewardToken.address);

        rewardToken.transfer(investor1.address, tokens('2000'));
        rewardToken.transfer(investor2.address, tokens('2000'));
        rewardToken.transfer(tokenFarming.address, tokens('99994000'));

        console.log("Executed as expected");
        
      });

      it("initial check : check the admin of the contracts,verify total token supply and balances of admin/investors ",async()=>{

        let tokenDeployer = await rewardToken.admin();
        expect(tokenDeployer).to.equal(owner.address);

        let farmDeployer = await tokenFarming.admin();
        expect(farmDeployer).to.equal(owner.address);

        let totalSupplyOfRewardToken = await rewardToken.totalSupply();
        expect(format(totalSupplyOfRewardToken)).to.equal('100000000.0');

        let ownerBalance = await rewardToken.balanceOf(owner.address);
        expect(format(ownerBalance)).to.equal('2000.0');

        let investor1Balance = await rewardToken.balanceOf(investor1.address);
        expect(format(investor1Balance)).to.equal('2000.0');

        let investor2Balance = await rewardToken.balanceOf(investor2.address);
        expect(format(investor2Balance)).to.equal('2000.0');

        let farmingBalance =  await rewardToken.balanceOf(tokenFarming.address);
        expect(format(farmingBalance)).to.equal('99994000.0');
      })

      it("Eth staking, minimum fail scenario", async()=>{

        let ethToStake = tokens('0.001');
        //const investor1EthBalance = await provider.getBalance(investor1.address);
        try{
            await tokenFarming.connect(investor1).StakeEth({value:ethToStake});
        }
        catch(ex){
            expect(ex.message.indexOf("Requireed minimmum 0.1 Eth to stake")>0).to.equal(true);
        }

      })

      it("Eth staking, stake 1.5 ETH and verify the staking balance and investor balance", async()=>{

        let ethToStake = tokens('1.5');

        await tokenFarming.connect(investor1).StakeEth({value:ethToStake});
        //1.investor balance reduced from staking value 
        // expect(format(await provider.getBalance(investor1.address))).to.lessThan('9998.5');
        //2.Eth balance in contract is increased by staking value
        expect(format(await tokenFarming.connect(investor1).balanceOfEthStaked())).to.equal('1.5');
        //3.Check user staked status 
        expect(await tokenFarming.connect(investor1).isUserStaked()).to.equal(true);
        //4.check eth staked value by investor
        expect(format(await tokenFarming.connect(investor1).getEthStaked())).to.equal('1.5');
        //5.Check rone staked value stayed same
        expect(format(await tokenFarming.connect(investor1).getRoneStaked())).to.equal('0.0');

      })
})