//import "./styles/Home.css";
import "./styles/VaporWave.css";
import { useContractRead, useContract } from "@thirdweb-dev/react";
import { useEffect, useState } from "react";
import { contractAddress } from "./data/contract";


export default function Home() {
  const { contract } = useContract(contractAddress);
  const { data, isLoading, error } = useContractRead(contract, "getCreatedOptions");
  const [parsedData, setParsedData] = useState("No Data");

  useEffect(() => {
    if (!isLoading && data !== null) {
      console.log(data)
      setParsedData(data)
    }
}, [data, isLoading]);

return (
  <article>
    <h2>My Owned Options</h2>
  <h3>APPLC200DE23</h3>
  <p>strikePrice: 200</p>
  <p>Batches: 1</p>
  <p>premium: 5</p>
  <p>signer:<b>0x999999cf1046e68e36E1aA2E0E07105eDDD1f08E</b></p> 
  <small>[EXAMPLE: APPLE CALL 200 1 Batch december2023]</small>
</article>
);
}
