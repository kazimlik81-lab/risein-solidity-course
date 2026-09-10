// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Fourth task: approve only with a strict majority of all cast votes.
contract ProposalVoting {
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
    mapping(uint256 => mapping(address => bool)) private voted_addresses;

    error NotOwner(address caller);
    error OwnerCannotVote();
    error InvalidOwner();
    error InvalidVoteChoice(uint8 choice);
    error InvalidVoteLimit();
    error ProposalNotFound(uint256 number);
    error ProposalInactive(uint256 number);
    error ActiveProposalExists(uint256 number);
    error AlreadyVoted(uint256 number, address voter);

    event ProposalCreated(
        uint256 indexed number,
        string title,
        string description,
        uint256 totalVoteToEnd
    );
    event VoteCast(uint256 indexed number, address indexed voter, uint8 choice);
    event ProposalTerminated(uint256 indexed number, bool approved);
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    modifier activeCheck() {
        if (counter == 0) revert ProposalNotFound(counter);
        if (!proposal_history[counter].is_active) revert ProposalInactive(counter);
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

    /// @param choice 0 = pass, 1 = approve, 2 = reject.
    function vote(uint8 choice) external activeCheck {
        if (msg.sender == owner) revert OwnerCannotVote();
        if (choice > 2) revert InvalidVoteChoice(choice);
        if (voted_addresses[counter][msg.sender]) {
            revert AlreadyVoted(counter, msg.sender);
        }

        Proposal storage proposal = proposal_history[counter];
        voted_addresses[counter][msg.sender] = true;

        if (choice == 1) {
            proposal.approve++;
        } else if (choice == 2) {
            proposal.reject++;
        } else {
            proposal.pass++;
        }

        proposal.current_state = calculateCurrentState();
        emit VoteCast(counter, msg.sender, choice);

        uint256 totalVotes = proposal.approve + proposal.reject + proposal.pass;
        if (totalVotes == proposal.total_vote_to_end) {
            closeCurrentProposal();
        }
    }

    function terminateProposal() external onlyOwner activeCheck {
        closeCurrentProposal();
    }

    /// @notice Approval must be a strict majority of all cast votes, including pass.
    function calculateCurrentState() private view returns (bool) {
        Proposal storage proposal = proposal_history[counter];
        return proposal.approve > proposal.reject + proposal.pass;
    }

    function closeCurrentProposal() private {
        Proposal storage proposal = proposal_history[counter];
        proposal.is_active = false;
        emit ProposalTerminated(counter, proposal.current_state);
    }

    function isVoted(address voter) public view returns (bool) {
        return voted_addresses[counter][voter];
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
