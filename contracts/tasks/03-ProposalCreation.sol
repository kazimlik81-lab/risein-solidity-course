// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Third task: accept and store a title when creating a proposal.
contract ProposalCreation {
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

    error NotOwner(address caller);
    error InvalidOwner();
    error InvalidVoteLimit();
    error ProposalNotFound(uint256 number);
    error ProposalInactive(uint256 number);
    error ActiveProposalExists(uint256 number);

    event ProposalCreated(
        uint256 indexed number,
        string title,
        string description,
        uint256 totalVoteToEnd
    );
    event ProposalTerminated(uint256 indexed number, bool approved);
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    function create(
        string calldata _title,
        string calldata _description,
        uint256 _total_vote_to_end
    ) external onlyOwner {
        if (_total_vote_to_end == 0) revert InvalidVoteLimit();
        if (counter != 0 && proposal_history[counter].is_active) {
            revert ActiveProposalExists(counter);
        }

        counter++;
        proposal_history[counter] = Proposal({
            title: _title,
            description: _description,
            approve: 0,
            reject: 0,
            pass: 0,
            total_vote_to_end: _total_vote_to_end,
            current_state: false,
            is_active: true
        });
        emit ProposalCreated(counter, _title, _description, _total_vote_to_end);
    }

    function setOwner(address new_owner) external onlyOwner {
        if (new_owner == address(0)) revert InvalidOwner();
        address previousOwner = owner;
        owner = new_owner;
        emit OwnerChanged(previousOwner, new_owner);
    }

    function terminateProposal() external onlyOwner {
        if (counter == 0) revert ProposalNotFound(counter);
        Proposal storage proposal = proposal_history[counter];
        if (!proposal.is_active) revert ProposalInactive(counter);
        proposal.is_active = false;
        emit ProposalTerminated(counter, proposal.current_state);
    }

    function getCurrentProposal() external view returns (Proposal memory) {
        if (counter == 0) revert ProposalNotFound(counter);
        return proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns (Proposal memory) {
        if (number == 0 || number > counter) revert ProposalNotFound(number);
        return proposal_history[number];
    }
}
