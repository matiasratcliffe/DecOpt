//import "./styles/Home.css";
import "./styles/VaporWave.css";
export default function Home() {
  return (
    <main className="main">
        <article className="article">
          <h2>Write option</h2>
          <form>
            <label>Underlying asset:
              <select name="underlyingAsset">
                <option value="NIFTY">NIFTY</option>
                <option value="BANKNIFTY">BANKNIFTY</option>
              </select>
            </label>
            <label>
                StrikePrice:
              <input type="text" name="strikePrice" />
            </label>
            <label>
                Batches:
              <input type="text" name="Batchs" />
            </label>
            <label>
                Premium:
              <input type="text" name="premium" className="input.small-input"/>
            </label>
            <input type="submit" value="Submit" className="btn" />
          </form>
        </article>
    </main>
  );
}
