# Safety Dance - Trustless LP Strategy

## **Trustless CFMM LP strategy with Axiom**

> LVR this, LVR that, why dont you lever some good ol' cryptography

Strategy that trustlessly and autonomously rebalances your liquidity into a wider position during times of high market volatility.

---

> Trade the vol with the comfort of a warm blanket

The strategy prioritizes LP safety during adverse market conditions. The implementation is as follows:

1. Check current price - price of previous block
2. If price gaps more than X%, trigger rebalance
3. Rebalance takes existing position and adds wide-range position

The strategy contracts uses Axiom to query the historical on-chain data for the pool. The spot price in the current block and previous block are retrieved and proved trustless on-chain.

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
