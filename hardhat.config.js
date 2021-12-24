/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-waffle");

const RINKEBY_RPC_URL= 'infura_rpc_url';
const PRIVATE_KEY = 'deployer account private key';
module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: RINKEBY_RPC_URL,
      accounts: [PRIVATE_KEY],
      //accounts: {
          //mnemonic: MNEMONIC,
      gas: 2100000,
      gasPrice: 8000000000,
      saveDeployments: true,
  },
  }
};
