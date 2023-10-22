const { ethers } = require("hardhat");
require('dotenv').config();

const contractAddress = process.env.GOERLI_CONTRACT_ADDRESS;

getSigner = async () => {
    return (await ethers.getSigners())[0];
}

getContract = async () => {
    const signer = await getSigner();
    return (await ethers.getContractAt("DecOpt", contractAddress)).connect(signer);
} 

addStock = async (ticker) => {
    let sourcePrefix = "https://api.polygon.io/v2/aggs/ticker/";
    let sourceSufix = "/prev?adjusted=true&apiKey=nftgOFIbfVHeJI3_A87GmZ5whQgBmBnc";
    const contract = await getContract();
    await contract.addStock(ticker, sourcePrefix + ticker + sourceSufix, "results,c");
};

module.exports = { getSigner, getContract, addStock };