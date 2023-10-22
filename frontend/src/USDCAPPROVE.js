import "./styles/VaporWave.css";
import { useContractRead, useContract } from "@thirdweb-dev/react";
import { ethers } from "ethers";
import { useEffect, useState } from "react";

const contractAddress = "0x07865c6e87b9f70255377e024ace6630c1eaa37f";

export default function USDCAPPROVE() {
    const { contract } = useContract(contractAddress);
    const { data, isLoading, error } = useContractRead(contract, "decimals");
    const [parsedData, setParsedData] = useState("No Data");
    const spender="0xE7009043daeD20AfF3B99cB5f399925508A2Dcd2"
    const value=10000*10**6
    let params = [spender, value];
    //let params = [spender, value];

    useEffect(() => {
        if (!isLoading && data !== null) {
            const parsedValue = ethers.BigNumber.from(data).toString();
            setParsedData(parsedValue);
        }
    }, [data, isLoading]);

    return (
        <div>            
            <button onClick={() => contract.call("approve",params)}>Incrementar</button>
        </div>
    );
}