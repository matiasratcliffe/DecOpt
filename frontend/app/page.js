"use client";

import styles from './page.module.css';
import WalletButton from './components/walletButton';
import { useEffect, useState } from "react";

export default function Home() {
  const [isConnected, setIsConnected] = useState(false);
  const [hasMetamask, setHasMetamask] = useState(false);
  const [signer, setSigner] = useState(undefined);

  return (
    <main className={styles.main}>
      <div className={styles.description}>
        <WalletButton isConnected={isConnected} setIsConnected={setIsConnected}></WalletButton>
      </div>
    </main>
  )
}
