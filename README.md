# v4-axiom-rebalancing

## ***Trustless v4 LP strategy with Axiom***

> LVR this, LVR that, why dont you lever some good ol' cryptography

Allow actors to trustlessly rebalance your liquidity

---

Because Axiom is used to observe market conditions, liquidity providers do not need to run their own infrastructure or delegate their capital to trusted managers. *Anyone* could modify your position (as long as market conditions are met)

Any actor can:

1. observe a change in market conditions
2. Upon a sufficient change in market conditions (defined by LPs), use Axiom to generate a proof and initiate execution
3. Rebalance someone's LP for a monetary incentive

## UniswapV4 and Axiom V2

> New York City's hotest new couple

UniV4 allows any developer to customize the rules and invocations of a liquidity pool. Axiom allows developers to trustless access ethereum historical data from their smart contract

Together we can build a liquidity pools that respond to market conditions and advanced calculations

---

## Demo (Goerli!)

[REPL gist](https://gist.github.com/saucepoint/5e36799b58b711a18542565b53888df0)

https://goerli.etherscan.io/tx/0x54ebd44a5181b809ff6c7753e603c2b58530b88eb96a7e0c3db0769dde18040d

https://goerli.etherscan.io/tx/0x3b8d13683a729fd6513f596d4899911dfa0366ca5408f365ca40e5cb14572e65

![Untitled-2023-09-25-1251](https://github.com/saucepoint/v4-axiom-rebalancing/assets/98790946/4784b47e-6d7a-41c4-abb1-6be017ee69cf)


---

_requires [foundry](https://book.getfoundry.sh)_

Additional resources:

[v4-periphery](https://github.com/uniswap/v4-periphery) contains advanced hook implementations that serve as a great reference

[v4-core](https://github.com/uniswap/v4-core)
