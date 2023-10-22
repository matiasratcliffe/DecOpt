//import "./styles/Home.css";
import "./styles/VaporWave.css";
import { useContractRead, useContract } from "@thirdweb-dev/react";
import { useEffect, useState } from "react";
import { contractAddress, usdcAddress } from "./data/contract";
import { ethers } from 'ethers';
import USDCAPPROVE from "./USDCAPPROVE";


export default function Home() {
  const { uscdContract } = useContract(usdcAddress);
  const { contract } = useContract(contractAddress);
  const { data, isLoading, error } = useContractRead(contract, "getStocks");
  const [tickers, setTickers] = useState([]);
  const [selectedStock, setSelectedStock] = useState();
  const [selectedStockPrice, setSelectedStockPrice] = useState();

  useEffect(() => {
    if (tickers.length > 0) {
      return;
    }
    if (!isLoading && data !== null) {
      let elements = [];
      data.forEach(element => {
        elements.push(
          <option value={element[1]}>{element[1]}</option>
        );
      });
      setTickers(elements);
      getStockValue();
    }
  }, [data, isLoading]);

  async function getStockValue() {
    if (!isLoading && data !== null && document.getElementById("stockSelector").value != "") { 
      let _selectedStock = data.filter((stock) => stock[1] === document.getElementById("stockSelector").value)[0];
      let endpoint = _selectedStock[4];
      await setSelectedStock(_selectedStock);
      await setSelectedStockPrice((await (await fetch(endpoint)).json()).results[0].c);
    } else {
      setSelectedStockPrice("-");
    }
  }

  async function createOption() {
    console.log(uscdContract);
    if (contract != null) {
      let params = [
        selectedStock[0],
        ethers.utils.parseEther(document.getElementById("strikePrice").value),
        ethers.utils.parseEther(document.getElementById("fee").value),
        document.getElementById("isCall").checked
      ];
      await contract.call("createOption", params);
    }
  }

  return (
    <main className="main">
        <article className="article">
          <h2>Write option</h2>
          <label>Underlying asset:
            <select name="underlyingAsset" id="stockSelector" onChange={getStockValue}>
              <option value="" disabled selected>Select stock</option>
              {tickers}
            </select>
          </label>
          <br/>
          <label>
            StockPrice: {selectedStockPrice}
          </label>
          <br/>
          <label>
            StrikePrice:
            <input type="text" name="strikePrice" id="strikePrice"/>
          </label>
          <br/>
          <label>
          premium:
            <input type="text" name="fee" className="input.small-input" id="fee"/>
          </label>
          <br/>
          <label>
            <input type="checkbox" id="isCall"/>
            Call
          </label>
          <br/>
          <USDCAPPROVE/>
          <button onClick={createOption}>Create Option</button>
        </article>
    </main>
  );
}
