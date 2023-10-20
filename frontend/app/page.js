import styles from './page.module.css';
import { useEffect, useState } from "react";

export default function Home() {
  const [isConnected, setIsConnected] = useState(false);
  const [hasMetamask, setHasMetamask] = useState(false);
  const [signer, setSigner] = useState(undefined);

  useEffect(() => {
    if (typeof window.ethereum !== "undefined") {
      setHasMetamask(true);
    }
  })

  function jajaja() {
    return 
  }

  return (
    <main className={styles.main}>
      <div className={styles.description}>
        {ethereum.toString()}

      </div>
    </main>
  )
}
