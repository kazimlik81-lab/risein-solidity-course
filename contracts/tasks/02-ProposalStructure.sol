// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Second task: extend the course's proposal structure with a title.
contract ProposalStructure {
    address public owner;
    uint256 private counter;

    struct Proposal {
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool current_state;
        bool is_active;
    }

    mapping(uint256 => Proposal) private proposal_history;

    constructor() {
        owner = msg.sender;
    }
}
