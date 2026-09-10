# Rise In Solidity coursework

Solutions for [Rise In — Learn everything about Solidity](https://www.risein.com/courses/solidity-fundamentals), covering the counter exercise and the proposal contract project.

## Source index

| Submission | Source | What it demonstrates |
| --- | --- | --- |
| First task | [01-Counter.sol](contracts/tasks/01-Counter.sol) | Owner-controlled counter with a stored description |
| Second task | [02-ProposalStructure.sol](contracts/tasks/02-ProposalStructure.sol) | Add a title to the course Proposal structure |
| Third task | [03-ProposalCreation.sol](contracts/tasks/03-ProposalCreation.sol) | Accept and store the title during proposal creation |
| Fourth task | [04-ProposalVoting.sol](contracts/tasks/04-ProposalVoting.sol) | Voting with a strict majority of all cast votes |
| Final project | [ProposalContract.sol](contracts/ProposalContract.sol) | Complete proposal creation, voting, history, ownership, and termination |

The task files are independent learning snapshots. Task 02 contains the structure; task 03 adds creation and management; task 04 adds voting. The final project contract is named `ProposalContract`.

## Final contract behavior

- `create(title, description, total_vote_to_end)` creates a proposal. The vote limit must be positive, and an active proposal must be closed before another is created.
- `vote(choice)` uses the course choices: `0 = pass`, `1 = approve`, `2 = reject`.
- Approval requires `approve > reject + pass`. Pass votes count toward all cast votes, so ties and zero votes result in false.
- Each address may vote once per proposal. The current owner cannot vote.
- Reaching the vote limit closes voting automatically. The owner may also close voting early with `terminateProposal()`.
- The owner alone may create proposals, terminate them, or call `setOwner(address)`. The zero address cannot become owner.
- `getCurrentProposal()`, `getProposal(number)`, and `isVoted(address)` retain the course interface. Proposal numbers begin at 1.

For example, 2 approve / 1 reject / 1 pass is false, while 3 approve / 1 reject / 1 pass is true. `current_state` is the running result while the proposal is active and the final result when it is closed.

## Verification status

Browser-based compilation and runtime verification are in progress. This repository does not yet record passing test results or a deployed network address.

The sources have MIT SPDX identifiers and no library dependencies. Use a compatible Solidity 0.8 compiler, version 0.8.20 or newer, to compile all exercises in Remix. The counter exercise also permits 0.8.18.

## Course scope

This contract holds no funds. One address is one vote; it does not establish one person per vote. The owner can finalize the running result early, and transferring ownership changes which address is excluded from subsequent voting.
