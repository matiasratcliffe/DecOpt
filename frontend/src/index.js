import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import reportWebVitals from "./reportWebVitals";
import { ThirdwebProvider } from "@thirdweb-dev/react";
import WrittenOptions from "./WrittenOptions";
import MyOptions from "./MyOptions";

import "./styles/VaporWave.css";
import { useContractRead, useContract } from "@thirdweb-dev/react";


//import "./styles/globals.css";
import "./styles/VaporWave.css";

// This is the chain your dApp will work on.
// Change this to the chain your app is built for.
// You can also import additional chains from `@thirdweb-dev/chains` and pass them directly.
const activeChain = "ethereum";
//clientId="your-client-id"
const container = document.getElementById("root");
const root = createRoot(container);

root.render(
  <React.StrictMode>
    <ThirdwebProvider activeChain="goerli">
      <App/>
      <WrittenOptions/>
      <MyOptions/>
    </ThirdwebProvider>
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
