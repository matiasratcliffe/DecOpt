//import "./styles/Home.css";
import "./styles/VaporWave.css";
import { useContractRead, useContract } from "@thirdweb-dev/react";
import { ethers } from "ethers";
import { useEffect, useState } from "react";

const contractAddress = "0x1f3413d43B40Ad50F1c580826D109F84b485c455";

export default function Home() {
  const { contract } = useContract(contractAddress);
  const { data, isLoading, error } = useContractRead(contract, "getOwnedOptions");
  const [options, setOptions] = useState([]);

  useEffect(() => {
    if (!isLoading && data !== null) {
      let articles = [];
      ([1,2]).forEach(element => {
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

  async function funcion() {
    console.log(contract);
  }

  return (
    <main className="main">
        <article className="article">
          <h2>My options</h2>
          {
            options.length
          }
          <button onClick={funcion}>Boton</button>
        </article>
    </main>
  );
}
