require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    development: {
      url: "http://localhost:8545",
    },
    goerli: {
      url: 'https://goerli.rpc.thirdweb.com',
      accounts: [process.env.GOERLI_PRIVATE_KEY],
    },
    mainnet: {
      url: "https://ethereum.rpc.thirdweb.com",
      contractAddresses: {
        usdtToken: "",
        cUsdtToken: "",
        linkToken: "",
        oracleAddress: "",
      },
    },
  },
};
