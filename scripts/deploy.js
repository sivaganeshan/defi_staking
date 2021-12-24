function tokens(n){
    return ethers.utils.parseEther(n);
}

async function main() {

    //1.To deploy Reward One token 
    let rewardOneTokenTotalSupply = 100000000
    const rewardOneToken = await ethers.getContractFactory("RewardTokenOne");
    const rewardOneTokenDeployed = await rewardOneToken.deploy(rewardOneTokenTotalSupply);

    //2.To deploy token farming
    const tokenFarming = await ethers.getContractFactory("TokenFarming");
    const tokenFarmingDeployed = await tokenFarming.deploy(rewardOneTokenDeployed.address);

    //3.Transfer rewardOneToken to addr1, addr2 and to farming smartcontract
    rewardOneTokenDeployed.transfer("addr1", tokens('2000'));
    rewardOneTokenDeployed.transfer("addr2", tokens('2000'));
    rewardOneTokenDeployed.transfer(tokenFarmingDeployed.address, tokens('99996000'));
  
    console.log(" Token address : ", rewardOneTokenDeployed.address);
    console.log(" token farming address : ", tokenFarmingDeployed.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });