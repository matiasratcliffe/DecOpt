"use client";

import { useEffect, useState } from "react";

export default function WalletButton(props) {
    const [isConnected, setIsConnected] = [props.isConnected, props.setIsConnected];
    const [hasMetamask, setHasMetamask] = useState(false);
    const setSigner = props.setSigner;
  
    useEffect(() => {
      if (typeof window.ethereum !== "undefined") {
        setHasMetamask(true);
      }
    })
  
    async function connect() {
      if (typeof window.ethereum !== "undefined") {
        try {
          await ethereum.request({ method: "eth_requestAccounts" });
          setIsConnected(true);
          const provider = new ethers.providers.Web3Provider(window.ethereum);
          setSigner(provider.getSigner());
        } catch (e) {
          console.log(e);
        }
      } else {
        setIsConnected(false);
      }
    }
  
    return (
      <main>
        <div>
          {hasMetamask ? (
            isConnected ? (
              "Connected!"
            ) : (
              <button onClick={() => connect()}>Connect</button>
            )
          ) : (
            "Please install metamask"
          )}
        </div>
      </main>
    )
  }
  