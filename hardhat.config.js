require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    development: {
      url: "http://localhost:8545",
    },
    mainnet: {
      url: "https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID",
      contractAddresses: {
        usdtToken: "",
        cUsdtToken: "",
        linkToken: "",
        oracleAddress: "",
      },
    },
  },
};
