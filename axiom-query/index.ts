import { Axiom, AxiomConfig } from "@axiom-crypto/core";
import {
  createPublicClient,
  createWalletClient,
  decodeEventLog,
  getContract,
  http,
  parseEther,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { goerli } from "viem/chains";

const RPC_URL = "https://rpc.ankr.com/eth_goerli";

const config: AxiomConfig = {
  providerUri: RPC_URL,
  version: "v1",
  chainId: 5,
  mock: true,
};
const ax = new Axiom(config);

const client = createPublicClient({
  chain: goerli,
  transport: http(RPC_URL),
});

const wallet = createWalletClient({
  account: privateKeyToAccount(process.env.PRIVATE_KEY! as `0x${string}`),
  chain: goerli,
  transport: http(RPC_URL),
});

console.log(wallet.account.address);

const axiomV1Query = getContract({
  address: ax.getAxiomQueryAddress() as `0x${string}`,
  abi: ax.getAxiomQueryAbi(),
  publicClient: client,
  walletClient: wallet,
});

const currentBlock = Number(await client.getBlockNumber());
console.log(currentBlock);

const qb = ax.newQueryBuilder();
const V4_POOL_MANAGER = "0x862Fa52D0c8Bca8fBCB5213C9FEbC49c87A52912";
await qb.append({
  blockNumber: currentBlock - 10,
  address: V4_POOL_MANAGER,
  slot: 10,
});

const { keccakQueryResponse, queryHash, query } = await qb.build();

const txHash = await axiomV1Query.write.sendQuery(
  [keccakQueryResponse, wallet.account.address, queryHash],
  {
    value: parseEther("0.01"),
  }
);
console.log(txHash);

// on query response
const unwatch = client.watchContractEvent({
  address: ax.getAxiomQueryAddress() as `0x${string}`,
  abi: ax.getAxiomQueryAbi(),
  eventName: "QueryFullfilled",
  onLogs: (logs) => {
    queryFulfilledHandler(logs);
    unwatch();
  },
});

async function queryFulfilledHandler(logs: any) {
  console.log(logs);
  // const responseTree = await ax.query.getResponseTreeForKeccakQueryResponse(
  //   keccakQueryResponse
  // );
}
