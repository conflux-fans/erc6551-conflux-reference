# ERC-6551 Reference Implementation

This repository contains the reference implementation of [ERC-6551](https://eips.ethereum.org/EIPS/eip-6551).

**This project is under active development and may undergo changes until ERC-6551 is finalized.** For the most recently deployed version of these contracts, see the [v0.2.0](https://github.com/erc6551/reference/releases/tag/v0.2.0) release. We recommend this version for any production usage.

## Using as a Dependency

If you want to use `erc6551/reference` as a dependency in another project, you can add it using `forge install`:

```sh
forge install erc6551=erc6551/reference
```

This will add `erc6551/reference` as a git submodule in your project. For more information on managing dependencies, refer to the [Foundry dependencies guide](https://github.com/foundry-rs/book/blob/master/src/projects/dependencies.md).

## Development Setup

You will need to have Foundry installed on your system. Please refer to the [Foundry installation guide](https://github.com/foundry-rs/book/blob/master/src/getting-started/installation.md) for detailed instructions.

To use this repository, first clone it:

```sh
git clone https://github.com/erc6551/reference.git
cd contracts
```

Then, install the dependencies:

```sh
forge install
```

## Running Tests

To run the tests, use the `forge test` command:

```sh
forge test
```

For more information on writing and running tests, refer to the [Foundry testing guide](https://github.com/foundry-rs/book/blob/master/src/forge/writing-tests.md).

## BytecodeLib

reference

* <https://blog.openzeppelin.com/deep-dive-into-the-minimal-proxy-contract>
* <https://www.rareskills.io/post/ethereum-contract-creation-code>
* <https://www.rareskills.io/post/eip-1167-minimal-proxy-standard-with-initialization-clone-pattern>
* <https://blog.openzeppelin.com/deconstructing-a-solidity-contract-part-ii-creation-vs-runtime-6b9d60ecb44c>

target: use [AdminSafe](./src/examples/AdminSafe.sol) constructor as proxy constructor

### codecopy pattern

PUSH1 60
DUP1 80
CODECOPY 39

60(length)8060(start point)6000396000

original: start 0xbe
length: 0x3f

### process

0x3060a452600060c4526044608090815260e4604081905260a080516001600160e01b031663c55b6bb760e01b17905261011160931b91603c916083565b6000604051808303816000865af19150503d80600081146077576040519150601f19603f3d011682016040523d82523d6000602084013e607c565b606091505b50505060b0565b6000825160005b8181101560a25760208186018101518583015201608a565b506000920191825250919050565b603f806100be6000396000f3fe(Compiled AdminSafe constructor)

=>

...603f806100be6000396000f3fe(AdminSafe constructor)

=>

...60(3f)8061(00be)6000396000f3fe(AdminSafe constructor)

3f: code length
00be: code start

== replace 3f with ad ==>

...60ad806100be6000396000f3fe(AdminSafe constructor)

=>

0x3060a452600060c4526044608090815260e4604081905260a080516001600160e01b031663c55b6bb760e01b17905261011160931b91603c916083565b6000604051808303816000865af19150503d80600081146077576040519150601f19603f3d011682016040523d82523d6000602084013e607c565b606091505b50505060b0565b6000825160005b8181101560a25760208186018101518583015201608a565b506000920191825250919050565b60ad806100be6000396000f3fe(New Proxy Constructor)

== join with original runtime bytecode==>

```solidity
abi.encodePacked(
    hex"3060a452600060c4526044608090815260e4604081905260a080516001600160e01b031663c55b6bb760e01b17905261011160931b91603c916083565b6000604051808303816000865af19150503d80600081146077576040519150601f19603f3d011682016040523d82523d6000602084013e607c565b606091505b50505060b0565b6000825160005b8181101560a25760208186018101518583015201608a565b506000920191825250919050565b60ad806100be6000396000f3fe",
    // hex"3d60ad80600a3d3981f3",
    hex"363d3d373d3d3d363d73",
    implementation_,
    hex"5af43d82803e903d91602b57fd5bf3",
    abi.encode(salt_, chainId_, tokenContract_, tokenId_)
);
```

## Conflux Mainnet Deployment

* ERC6551AdminSafeRegistry: cfx:ach1zpmjyv17arzdjx9fgbt4cw6uns0ntuwre8sdsy
* ERC6551AccountUpgradeableImpl: cfx:acd9jgz4d5as156ef08r5mdgux28y51yz639nr5s78

> notice that this is the implementation of upgradeable but not actually upgradeable if it is not deployed with a proxy
> We reuse the upgradable implentation for the 721, 1155 receiver implementation as well as ownership cycle check
> Use `cfx:acd9jgz4d5as156ef08r5mdgux28y51yz639nr5s78` as the implementation if an in-upgradeable version is desired
> otherwise use a proxy pointing to the impl (proxy not yet deployed)
