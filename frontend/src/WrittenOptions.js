//import "./styles/Home.css";
import "./styles/VaporWave.css";
import { useContractRead, useContract } from "@thirdweb-dev/react";
import { useEffect, useState } from "react";
require('dotenv').config();

const contractAddress = process.env.GOERLI_CONTRACT_ADDRESS;


export default function Home() {
  const { contract } = useContract(contractAddress);
  const { data, isLoading, error } = useContractRead(contract, "getStocks");
  const [stocks, setStocks] = useState([]);
  const [selectedStock, setSelectedStock] = useState();

  useEffect(() => {
    if (!isLoading && data !== null) {
      let elements = [];
      data.forEach(element => {
        console.log(element);
        elements.push(
          <option value="NIFTY">NIFTY</option>
        );
      });
      setOptions(articles);
    }
  }, [data, isLoading]);

  return (
    <main className="main">
        <article className="article">
          <h2>Write option</h2>
          <form>
            <label>Underlying asset:
              <select name="underlyingAsset">
                {stocks}
              </select>
            </label>
            <label>
                StrikePrice:
              <input type="text" name="strikePrice" />
            </label>
            <label>
                Batches:
              <input type="text" name="Batchs" />
            </label>
            <label>
                Premium:
              <input type="text" name="premium" className="input.small-input"/>
            </label>
            <input type="submit" value="Submit" className="btn" />
          </form>
        </article>
    </main>
  );
}
