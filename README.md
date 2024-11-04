## 一个质押挖矿合约，实现如下功能:
-   用户随时可以质押项目方代币 RNT(自定义的ERC20)，开始赚取项目方Token(esRNT);
-   可随时解押提取已质押的 RNT;
-   可随时领取esRNT奖励，每质押1个RNT每天可奖励 1eSRNT;
-   RNT 是锁仓性的 RNT,1eSRNT 在 30 天后可兑换 1RNT，随时间线性释放，支持提前将 esRNT 兑换成 RNT，但锁定部分将被 burn 燃烧掉。

## 实现功能(用户端操作):
-   质押RNT
-   取消质押RNT,提取出RNT
-   兑换esRNT为RNT，并提取出来对应数量的RNT，但提前解锁需要燃烧掉锁定部分的esRNT



## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
