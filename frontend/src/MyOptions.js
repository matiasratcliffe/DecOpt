//import "./styles/Home.css";
import "./styles/VaporWave.css";
import { useContractRead, useContract } from "@thirdweb-dev/react";
import { useEffect, useState } from "react";
require('dotenv').config();

const contractAddress = process.env.GOERLI_CONTRACT_ADDRESS;

export default function Home() {
  const { contract } = useContract(contractAddress);
  const { data, isLoading, error } = useContractRead(contract, "getOwnedOptions");
  const [options, setOptions] = useState([]);

  useEffect(() => {
    if (!isLoading && data !== null) {
      let articles = [];
      data.forEach(element => {
        console.log(element);
        articles.push(
          <article>
            <h3>GFGC1517MA</h3>
            <p>strikePrice: 700</p>
            <p>Batches: 1</p>
            <p>premium: 100</p>
            <p>signer:<b>0x999999cf1046e68e36E1aA2E0E07105eDDD1f08E</b></p> 
          </article>
        );
      });
      setOptions(articles);
    }
  }, [data, isLoading]);

  return (
    <main className="main">
        <article className="article">
          <h2>My options</h2>
          {options}
        </article>
    </main>
  );
}
