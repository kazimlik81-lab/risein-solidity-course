# Arc Testnet deployment and validation

## Deployment record

| Field | Verified value |
| --- | --- |
| Network | Arc Testnet |
| Chain ID | `5042002` |
| Contract | `ProposalContract` |
| Address | `0x7016623d011dFfFA3876F4eB55C99CD36bf0e9eE` |
| Transaction | `0x34535b386e7a3b3c38f4a5ce88defc6aa94fb5c5aac2518200f2b67d3247bd59` |
| Block | `61446669` |
| Owner at verification | `0x33f180A18109aaBf616FbA456E720Ab1Df65998F` |

[Open the deployed contract on Arc Testnet explorer](https://testnet.arcscan.app/address/0x7016623d011dFfFA3876F4eB55C99CD36bf0e9eE).

Deployment succeeded. Deployed bytecode presence and the value returned by `owner()` were verified on Arc Testnet.

## Source and compiler

- Source: [ProposalContract.sol](../contracts/ProposalContract.sol). The source opened in Remix matched the prepared source.
- Solidity compiler: `0.8.34+commit.80d5c536`.
- Optimizer: enabled, `200` runs.
- EVM target: `prague`.

## Runtime validation

**33 checks passed** in a browser-based Remix script using ethers `5.8.0`. The checks covered:

- Counter getters, increment, decrement, and owner restrictions.
- Proposal title storage, positive vote limits, and owner-controlled operations.
- Rejection of missing proposal IDs, invalid vote choices, duplicate votes, and votes by the current owner.
- Strict majority of all cast votes, including pass votes, and failure on ties.
- Automatic closure at the vote limit and manual closure by the owner.
- Voter reuse in subsequent proposals and preservation of proposal history.
- Ownership transfer.

The deployment verification and the Remix runtime checks are separate recorded results. The detailed deployed-contract values above were checked on Arc Testnet.
