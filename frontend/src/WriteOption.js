//import "./styles/Home.css";
import "./styles/VaporWave.css";
export default function Home() {
  return (
    <main className="main">
        <article className="article">
          <h2>Write option</h2>
          <form>
            <label>
                StrikePrice:
              <input type="text" name="strikePrice" />
            </label>
            <label>
                Lots:
              <input type="text" name="lots" />
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
