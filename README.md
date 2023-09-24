# v4-axiom-rebalancing
## **Trustless v4 LP Rebalancing with Axiom proofs**

> LVR this, LVR that, why dont you lever some good ol' cryptography

 *anyone* could modify your LP

---

LP Rebalancing: adjusting the ratio of assets in an LP (in response to market conditions) is achieved via:

1. Manual intervention, burn and re-mint LPs with Uniswap Interface
2. Bot intervention, run your own bots to manage your own position
3. Trusted 3rd party services, trust that LP managers are acting according to your preferences

With axiom-powered rebalancing, trustless rebalancing is enabled where *anyone* can modify your LP according to defined market conditions.

---

In this example hook, if `token0`'s spot price falls 5% compared to 1 hour ago, rebalance their LP to ratios TODO-XYZ

Process:
1. Query spot price of the pool as of 1 hour ago
2. Submits the query to onchain AxiomV1Query contract
3. Obtain proof data from query fulfillment
4. Provide proof data to the LP Router
5. LP Router forwards proof data to `hook.beforeModifyPosition`
6. Proof data enables LP modification!

---

## Demo (Goerli!)
*requires [foundry](https://book.getfoundry.sh)*

*requires [bun](bun.sh)*

```
cd axiom-query
bun run index.ts
```

---

Additional resources:

[v4-periphery](https://github.com/uniswap/v4-periphery) contains advanced hook implementations that serve as a great reference

[v4-core](https://github.com/uniswap/v4-core)

