import { ConnectWallet } from "@thirdweb-dev/react";
//import "./styles/Home.css";
import "./styles/VaporWave.css";
export default function Home() {
  return (
    <main className="main">
      <div className="top-right-div">
            <ConnectWallet
              dropdownPosition={{
                side: "top",
                align: "left",
              }}
            />
          </div>
        <div className="header">
          <h1 className="headline">
            Welcome to Dec Options!
          </h1>
        </div>
    </main>
  );
}
