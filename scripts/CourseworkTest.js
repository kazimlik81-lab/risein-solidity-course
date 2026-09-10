// Run in Remix VM after compiling Counter (Example) and ProposalContract.
// Artifacts expected at browser/artifacts/Example.json and browser/artifacts/ProposalContract.json.
const { ethers } = require('ethers');
(async () => {
  try {
    const provider = new ethers.providers.Web3Provider(web3Provider);
    const signers = Array.from({length: 7}, (_, i) => provider.getSigner(i));
    const addresses = await Promise.all(signers.map(s => s.getAddress()));
    let checks = 0;
    function check(value, label) { if (!value) throw new Error(label); checks++; console.log('PASS: ' + label); }
    async function rejected(action, selector, label) {
      let error;
      try { await action(); } catch (caught) { error = caught; }
      if (!error) throw new Error('Expected revert: ' + label);
      const details = JSON.stringify(error);
      check(details.toLowerCase().includes(selector.toLowerCase()), label);
    }
    const counterArtifact = JSON.parse(await remix.call('fileManager','getFile','browser/artifacts/Example.json'));
    const counter = await new ethers.ContractFactory(counterArtifact.abi,counterArtifact.data.bytecode.object,signers[0]).deploy(5,'Rise In counter');
    await counter.deployed();
    check((await counter.get_counter_value()).eq(5),'Counter starts at 5');
    check((await counter.get_counter_description()) === 'Rise In counter','Description getter');
    await (await counter.increment_counter()).wait();
    check((await counter.get_counter_value()).eq(6),'Counter increments');
    await (await counter.decrement_counter()).wait();
    check((await counter.get_counter_value()).eq(5),'Counter decrements');
    await rejected(() => counter.connect(signers[1]).callStatic.increment_counter(),'0x08c379a0','Counter owner protection');
    const artifact = JSON.parse(await remix.call('fileManager','getFile','browser/artifacts/ProposalContract.json'));
    const proposal = await new ethers.ContractFactory(artifact.abi,artifact.data.bytecode.object,signers[0]).deploy();
    await proposal.deployed();
    const signature = name => proposal.interface.getSighash(name);
    await rejected(() => proposal.callStatic.getCurrentProposal(),signature('ProposalNotFound'),'Missing proposal rejected');
    await rejected(() => proposal.callStatic.create('Title','Description',0),signature('InvalidVoteLimit'),'Zero limit rejected');
    await rejected(() => proposal.connect(signers[1]).callStatic.create('Title','Description',4),signature('NotOwner'),'Only owner creates');
    await (await proposal.create('Learning proposal','Fund a workshop',4)).wait();
    let current = await proposal.getCurrentProposal();
    check(current.title === 'Learning proposal' && current.description === 'Fund a workshop','Title and description stored');
    check(!current.current_state && current.is_active,'Initial state active and false');
    await rejected(() => proposal.callStatic.create('Replacement','Not allowed',1),signature('ActiveProposalExists'),'Active proposal protected');
    await rejected(() => proposal.callStatic.vote(1),signature('OwnerCannotVote'),'Owner cannot vote');
    await rejected(() => proposal.connect(signers[2]).callStatic.vote(3),signature('InvalidVoteChoice'),'Invalid choice rejected');
    check(!(await proposal.isVoted(addresses[2])),'Invalid choice preserves voting right');
    await (await proposal.connect(signers[1]).vote(1)).wait();
    check(await proposal.isVoted(addresses[1]),'Voter recorded');
    await rejected(() => proposal.connect(signers[1]).callStatic.vote(1),signature('AlreadyVoted'),'Duplicate vote rejected');
    await (await proposal.connect(signers[2]).vote(0)).wait();
    check(!(await proposal.getCurrentProposal()).current_state,'Approve/pass tie fails');
    await (await proposal.connect(signers[3]).vote(1)).wait();
    check((await proposal.getCurrentProposal()).current_state,'Strict majority succeeds');
    await (await proposal.connect(signers[4]).vote(0)).wait();
    current = await proposal.getCurrentProposal();
    check(current.approve.eq(2) && current.pass.eq(2) && current.reject.eq(0),'Counts preserved');
    check(!current.current_state && !current.is_active,'Two approves plus two passes fail and auto-close');
    await rejected(() => proposal.connect(signers[5]).callStatic.vote(1),signature('ProposalInactive'),'Voting after close rejected');
    await (await proposal.create('Second','Manual ending',3)).wait();
    check(!(await proposal.isVoted(addresses[1])),'Voter tracking resets for new proposal');
    await (await proposal.connect(signers[1]).vote(2)).wait();
    await (await proposal.connect(signers[2]).vote(1)).wait();
    current = await proposal.getCurrentProposal();
    check(current.reject.eq(1) && current.approve.eq(1) && !current.current_state,'Approve/reject tie fails');
    await rejected(() => proposal.connect(signers[3]).callStatic.terminateProposal(),signature('NotOwner'),'Only owner terminates');
    await (await proposal.terminateProposal()).wait();
    check(!(await proposal.getCurrentProposal()).is_active,'Manual termination');
    await (await proposal.create('Third','Reuse after termination',1)).wait();
    await (await proposal.connect(signers[1]).vote(1)).wait();
    check((await proposal.getCurrentProposal()).current_state && !(await proposal.getCurrentProposal()).is_active,'Voter reused after termination');
    check((await proposal.getProposal(1)).title === 'Learning proposal','Historical proposal preserved');
    await rejected(() => proposal.callStatic.getProposal(0),signature('ProposalNotFound'),'Zero history id rejected');
    await rejected(() => proposal.callStatic.getProposal(4),signature('ProposalNotFound'),'Future history id rejected');
    await rejected(() => proposal.callStatic.setOwner(ethers.constants.AddressZero),signature('InvalidOwner'),'Zero owner rejected');
    await rejected(() => proposal.connect(signers[1]).callStatic.setOwner(addresses[1]),signature('NotOwner'),'Only owner transfers ownership');
    await (await proposal.setOwner(addresses[5])).wait();
    check((await proposal.owner()) === addresses[5],'Ownership transferred');
    await rejected(() => proposal.callStatic.create('Old owner','Denied',1),signature('NotOwner'),'Previous owner loses control');
    console.log('RISE_IN_TEST_SUCCESS: ' + checks + ' checks passed; ethers=' + ethers.version);
  } catch (error) { console.error('RISE_IN_TEST_FAILURE', error.message); }
})();
