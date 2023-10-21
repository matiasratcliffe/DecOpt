import "./styles/VaporWave.css";
import { useContractRead, useContract } from "@thirdweb-dev/react";
import { ethers } from "ethers";
import { useEffect, useState } from "react";

const contractAddress = "0x232b57323b4179969DeeA3d85395041040CBF200";

export default function MyComponent() {
    const { contract } = useContract(contractAddress);
    const { data, isLoading, error } = useContractRead(contract, "getCurrentCount");
    const [parsedData, setParsedData] = useState("No Data");
    
    useEffect(() => {
        if (!isLoading && data !== null) {
            const parsedValue = ethers.BigNumber.from(data).toString();
            setParsedData(parsedValue);
        }
    }, [data, isLoading]);

    return (
        <div>
            <h1>Number: {parsedData}</h1>
            <button onClick={() => contract.call("incrementCounter", [])}>Incrementar</button>
        </div>
    );
}