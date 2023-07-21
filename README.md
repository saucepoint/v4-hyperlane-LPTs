# v4-hyperlane-LPTs
### **Automated cross-chain LPTs with Uniswap v4 Hooks 🦄 and Hyperlane ⏩️**

> *Produced during the Modular Hacker House (EthCC 2023)*

![Untitled-2023-07-21-2023 (1)](https://github.com/saucepoint/v4-hyperlane-LPTs/assets/98790946/ff4e0325-4c11-4cdf-beac-3e6d28b7b1ee)

With rollups-as-a-service (RaaS) app-chains becoming popular, new networks will want to incentivize TVL and liquidity. To reduce friction, I've set up an *experimental* v4 hook that can notify destination chains of liquidity provisioning.

These destination chains can offer incentives such as:
1. Token emissions
2. Game cosmetics & collectibles
3. Token-gated access

---

#### A note on Hooks vs. Bespoke Rewards

An alternative to this implementation is using bespoke contracts:

1. Users provision liquidity on Uniswap Interface
2. Users receive LP tokens
3. Users stake their LP tokens in a bespoke contract
    - the bespoke contract handles the cross-chain communications

This sequence involves multiple steps and constrains the user to using Uniswap's canonical position manager. In this repo, liquidity provisioning *from anywhere* will automatically trigger the cross-chain communication 

---

### Local Development (Anvil and Polaris)

Because v4 exceeds the bytecode limit of Ethereum and its *business licensed*, we can only deploy & test hooks on [anvil](https://book.getfoundry.sh/anvil/).

1. Clone [`polaris`](https://github.com/berachain/polaris) to act as our destination chain (Ran locally too)

2. Clone [`hyperlane-deploy`](https://github.com/hyperlane-xyz/hyperlane-deploy) for the deployment scripts of Hyperlane Mailboxes

3. Copy `demo.sh` to `hyperlane-deploy/`

```bash
# start anvil, with a larger code limit
anvil --port 8555 --chain-id 31338 --block-time 2 

# -- in polaris/ -- #
# start polaris on localhost:8545
mage start

# -- in hyperlane-deploy/ -- #
# deploy hyperlane contracts & start up infra
./demo.sh


# deploy the Reward token and Staking contract to polaris
forge script script/DeployBenefits.s.sol \
    --rpc-url http://localhost:8545 \
    --private-key 0xfffdbb37105441e14b0ee6330d855d8504ff39e705c3afa8f859ac9865f99306 \
    --broadcast

# edit the script to point to the proper addresses
# deploy v4, the HyperlaneLPHook, and provision liquidity
forge script script/DeployAndProvision.s.sol \
    --rpc-url http://localhost:8555 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    --broadcast

# read the benefits contract for issuance
cast call 0x6B1e75149F6a154988Bb36Fa0C0AF35C8000eC60 "earned(address)(uint256)" 0xd85BdcdaE4db1FAEB8eF93331525FE68D7C8B3f0 --rpc-url http://localhost:8545
```

---

Additional resources:

[v4-periphery](https://github.com/uniswap/v4-periphery) contains advanced hook implementations that serve as a great reference

[v4-core](https://github.com/uniswap/v4-core)

---

*requires [foundry](https://book.getfoundry.sh)*

```
forge install
forge test
```
