# v4-axiom-rebalancing

## ***Trustless v4 LP strategy with Axiom***

> LVR this, LVR that, why dont you lever some good ol' cryptography

Allow any actor to trustlessly rebalance your liquidity into a wider range during times of high market volatility

---

> Trade the vol with the comfort of a warm blanket

Because Axiom is used to observe market conditions, liquidity providers do not need to run their own 

1. Observe a change in market conditions
2. If price gaps more than X%, trigger rebalance
3. Rebalance takes existing position and adds wide-range position

## UniswapV4 and Axiom V2

> New York City's hotest new couple

UniV4 allows any developer to customize the rules and invocations of a liquidity pool. Axiom allows developers to trustless access ethereum historical data from their smart contract.

Together we can build a liquidity pools that respond to market conditions and advanced calculations.

---

## Demo (Goerli!)

_requires [foundry](https://book.getfoundry.sh)_

_requires [bun](bun.sh)_

```
cd axiom-query
bun run index.ts
```

---

Additional resources:

[v4-periphery](https://github.com/uniswap/v4-periphery) contains advanced hook implementations that serve as a great reference

[v4-core](https://github.com/uniswap/v4-core)
