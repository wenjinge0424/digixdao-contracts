import "./Token.sol";
import "./Interfaces.sol";

contract Proposal {

  struct PledgeData {
    uint256 startDate;
    uint256 endDate;
    mapping (address => uint256) balances;
    uint256 totalApproves;
    uint256 totalDeclines;
    bool resolved;
  }

  struct VoteData {
    uint256 startDate;
    uint256 endDate;
    mapping (address => uint256) balances;
    uint256 totalApproves;
    uint256 totalDeclines;
    bool resolved;
  }

  enum Status { Pledging, FailPledge, Voting, FailVote, Completed }

  address public proposer;
  address public provider;
  address public badgeLedger;
  address public tokenLedger;
  uint256 public minPledges;
  uint256 public minVotes;
  bool public dissolve;
  PledgeData pledgeData;
  VoteData voteData;
  bytes32 public environment;

  event Pledge(address indexed _pledger, uint256 indexed _amount, bool indexed _approve);
  event Vote(address indexed _pledger, uint256 indexed _amount, bool indexed _approve);

  modifier onlyAfter(uint _time) {
    if (now < _time) throw;
    _
  }

  modifier onlyBefore(uint _time) {
    if (now > _time) throw;
    _
  }
  
  /// @notice Create a new proposal
  /// @param _config The address for the configuration contract
  /// @param _badgeledger The address for the badge contract
  /// @param _tokenledger The address for the token contract
  /// @param _environment The environment 'mainnet', 'morden', or 'testnet'
  /// @param _dissolve Whether or not this is a proposal to dissolve the contract

  function Proposal(address _config, address _badgeledger, address _tokenledger, bytes32 _environment, bool _dissolve) {
    proposer = tx.origin;
    badgeLedger = _badgeledger;
    tokenLedger = _tokenledger;
    minPledges = ConfigInterface(_config).getConfigUint("pledges:minimum");
    minVotes = ConfigInterface(_config).getConfigUint("votes:minimum") * 1000000000;
    provider = ConfigInterface(_config).getConfigAddress("provider:address");
    pledgeData.totalApproves = 0;
    pledgeData.totalDeclines = 0;
    pledgeData.resolved = false;
    voteData.totalApproves = 0;
    voteData.totalDeclines = 0;
    voteData.resolved = false;
    pledgeData.startDate = now;
    dissolve = _dissolve;
    environment = _environment;
    if (dissolve) {
      if (environment == "mainnet") pledgeData.endDate = now + 1 weeks;
      if (environment == "testnet") pledgeData.endDate = now + 20 minutes;
      if (environment == "morden") pledgeData.endDate = now + 1 days;
    } else {
      if (environment == "mainnet") pledgeData.endDate = now + 1 years;
      if (environment == "testnet") pledgeData.endDate = now + 20 minutes;
      if (environment == "morden") pledgeData.endDate = now + 1 days;
    }
    environment = environment;
  }



  /// @notice Approve the pledge
  /// @return `success` whether or not the call succeeded

  function pledgeApprove(uint256 _amount) returns (bool success) {
    return pledge(true, _amount);
  }
  
  /// @notice Decline the pledge
  /// @return `success` whether or not the call succeeded

  function pledgeDecline(uint256 _amount) returns (bool success) {
    return pledge(false, _amount);
  }

  /// @notice Send a pledge on the proposal
  /// @param _pledge Send true to approve or false to decline
  /// @return `success` whether or not the call succeeded

  function pledge(bool _pledge, uint256 _amount) onlyAfter(pledgeData.startDate) onlyBefore(pledgeData.endDate) internal returns (bool success) {
    if (!Badge(badgeLedger).transferFrom(msg.sender, address(this), _amount)) {
      success = false;
    } else {
      if (_pledge == true) pledgeData.totalApproves += _allowance;
      if (_pledge == false) pledgeData.totalDeclines += _allowance;
      pledgeData.balances[msg.sender] = _allowance;
      Pledge(msg.sender, _amount, _pledge);
      success = true;
    }
    return success;
  }

  /// @notice Get information about the proposal
  /// @return `istatus` The status of the proposal
  /// @return `pstartdate` The pledging start date
  /// @return `penddate` The pledging end date
  /// @return `papproves` The number of approve pledges
  /// @return `pdeclines` The number of decline pledges
  /// @return `ptotals` The total number of pledges
  /// @return `vstartdate` The voting start date
  /// @return `venddate` The voting end date
  /// @return `vapproves` The number of approve votes
  /// @return `vdeclines` The number of decline votes
  /// @return `vtotals` The total number of votes

  function getInfo() public constant returns (uint8 istatus, uint256 pstartdate, uint256 penddate, uint256 papproves, uint256 pdeclines, uint256 ptotals, uint256 vstartdate, uint256 venddate, uint256 vapproves, uint256 vdeclines, uint256 vtotals) {
    (pstartdate, penddate, papproves, pdeclines, ptotals) = (pledgeData.startDate, pledgeData.endDate, pledgeData.totalApproves, pledgeData.totalDeclines, (pledgeData.totalApproves + pledgeData.totalDeclines));
    (vstartdate, venddate, vapproves, vdeclines, vtotals) = (voteData.startDate, voteData.endDate, voteData.totalApproves, voteData.totalDeclines, (voteData.totalApproves + voteData.totalDeclines));
    return (getStatus(), pstartdate, penddate, papproves, pdeclines, ptotals, vstartdate, venddate, vapproves, vdeclines, vtotals);
  }

  function getStatus() public constant returns (uint8 status) {
    return uint8(Status.Voting);
  } 

  function getUserInfo(address _user) public constant returns (uint256 pledgecount, uint256 votecount) {
    return (pledgeData.balances[_user], voteData.balances[_user]);
  }

  function getMyInfo() public constant returns (uint256 pledgecount, uint256 votecount) {
    return getUserInfo(msg.sender);
  }

  function voteApprove() returns (bool success) {
    return vote(true);
  }

  function voteDecline() returns (bool success) {
    return vote(false);
  }

  function vote(bool _vote) returns (bool success) {
    return true;
  }

  function resolve() returns (bool success) {
    return true;
  }

  function releaseBadges() returns (bool success) {
    return true;
  }

  function releaseTokens() returns (bool success) {
    return true;
  }

  function budget() public constant returns (uint256 _weibudget) {
    return address(this).balance;
  }

}

contract Dao {
  
  struct ProposalData {
    uint256 budget;
    bytes32 document;
  }

  address public config;
  address public owner;
  address public tokenLedger;
  address public badgeLedger;
  mapping (uint256 => address) tokenSales;
  mapping (address => ProposalData) proposals;
  mapping (uint256 => address) proposalIndex;
  uint256 public proposalsCount;
  bytes32 public environment;

  enum Status { Pledging, Voting, Completed }

  event NewProposal(address indexed _proposal, bytes32 indexed _document, uint256 indexed _budget);

  function Dao(address _config) {
    config = _config;
    owner = msg.sender;
    tokenLedger = ConfigInterface(config).getConfigAddress("ledger");
    environment = ConfigInterface(config).getConfigBytes("environment");
    badgeLedger = Token(tokenLedger).badgeLedger();
    proposalsCount = 0;
  }

  function iPropose(bytes32 _document, uint256 _weibudget, bool _dissolve) internal returns (bool success) {
    if (Badge(badgeLedger).balanceOf(msg.sender) <= 0) throw;
    if (_weibudget > funds()) throw;
    address _proposal = new Proposal(config, badgeLedger, tokenLedger, environment, _dissolve);
    proposals[_proposal].budget = _weibudget;
    proposals[_proposal].document = _document;
    proposalsCount++;
    proposalIndex[proposalsCount] = _proposal;
    NewProposal(_proposal, _document, _weibudget);
    return true;
  }

  function propose(bytes32 _document, uint256 _weibudget) returns (bool success) {
    return (iPropose(_document, _weibudget, false));
  }

  function proposeDissolve(bytes32 _document) returns (bool success) {
    uint256 _weibudget = funds();
    return (iPropose(_document, _weibudget, true));
  }

  function getProposal(uint256 _index) public constant returns (address proposal) {
    return proposalIndex[_index];
  }

  function funds() public constant returns (uint256 weifunds) {
    return address(this).balance;
  }

  function partsPerBillion(uint256 _a, uint256 _c) returns (uint256 b) {
    b = (1000000000 * _a + _c / 2) / _c;
    return b;
  }

  function calcShare(uint256 _antecedent, uint256 _consequent, uint256 _amount) returns (uint256 share) {
    uint256 _ppb = partsPerBillion(_antecedent, _consequent);
    share = ((_ppb * _amount) / 1000000000);
    return share;
  }

}
