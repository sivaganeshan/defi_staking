const {expect} = require('chai');
const { ethers } = require("hardhat");

describe("RewardTokenOneContractBaseTests", async()=>{

    it("Verifying token name and total supply", async ()=>{
        //get account from hardhat node
        const [owner] = await ethers.getSigners();
        //Load smartcontract 
        const token = await ethers.getContractFactory("RewardTokenOne");
        //Deploy smartcontract with the constrctor parameter
        let tokensupply = 1000000;
        const tokendeploy = await token.deploy(tokensupply);
        console.log(`contract address : `, tokendeploy.address );
        //Owner balance
        const ownerBalance = await tokendeploy.balanceOf(owner.address);
        console.log(`owner's address : ${owner.address} with the balance of ${ethers.utils.formatEther(ownerBalance)}`);
        //token name
        let name = await tokendeploy.name();
        console.log(`token's name : ${name}`);
        expect(name).to.equal("RewardTokenOne");
        //total supply
        let totalSupply = await tokendeploy.totalSupply();
        expect(totalSupply).to.equal(ownerBalance);
        console.log(`token's total supply : ${ethers.utils.formatEther(totalSupply)}`);

    })
})