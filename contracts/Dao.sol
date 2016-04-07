import "./Token.sol";
import "./Interfaces.sol";

contract Proposal {

  struct PledgeData {
    uint256 startDate;
    uint256 endDate;
    mapping (address => uint256) balances;
    uint256 totalApproves;
    uint256 totalDeclines;
  }

  struct VoteData {
    uint256 startDate;
    uint256 endDate;
    mapping (address => uint256) balances;
    uint256 totalApproves;
    uint256 totalDeclines;
  }

  enum Status { New, Pledging, Pledged, Voting, Completed }

  address public proposer;
  address public provider;
  address public badgeLedger;
  address public tokenLedger;
  uint256 public minPledges;
  uint256 public minVotes;
  PledgeData pledgeData;
  VoteData voteData;
  uint8 public status;

  event Pledge(address indexed _pledger, uint256 indexed _amount, bool indexed _approve);
  event Vote(address indexed _pledger, uint256 indexed _amount, bool indexed _approve);

  function Proposal(address _config) {
    proposer = tx.origin;
    minPledges = ConfigInterface(_config).getConfigUint("pledges:minimum");
    minVotes = ConfigInterface(_config).getConfigUint("votes:minimum") * 1000000000;
    provider = ConfigInterface(_config).getConfigAddress("provider:address");
  }

  function pledgeApprove() returns (bool success) {
    return pledge(true);
  }

  function pledgeDecline() returns (bool success) {
    return pledge(false);
  }

  function pledge(bool _pledge) returns (bool success) {
    uint256 _allowance = Badge(badgeLedger).allowance(msg.sender, address(this));
    if (_allowance <= 0) return false;
    if (!Badge(badgeLedger).transferFrom(msg.sender, address(this), _allowance)) return false;
    if (_pledge == true) pledgeData.totalApproves += _allowance;
    if (_pledge == false)  pledgeData.totalDeclines += _allowance;
    pledgeData.balances[msg.sender] = _allowance;
    Pledge(msg.sender, _allowance, _pledge);
    return true;
  }

  function getInfo() public constant returns (uint256 pstartdate, uint256 penddate, uint256 papproves, uint256 pdeclines, uint256 ptotals, uint256 vstartdate, uint256 venddate, uint256 vapproves, uint256 vdeclines, uint256 vtotals) {
    (pstartdate, penddate, papproves, pdeclines, ptotals) = (pledgeData.startDate, pledgeData.endDate, pledgeData.totalApproves, pledgeData.totalDeclines, (pledgeData.totalApproves + pledgeData.totalDeclines));
    (vstartdate, venddate, vapproves, vdeclines, vtotals) = (voteData.startDate, voteData.endDate, voteData.totalApproves, voteData.totalDeclines, (voteData.totalApproves + voteData.totalDeclines));
    return (pstartdate, penddate, papproves, pdeclines, ptotals, vstartdate, venddate, vapproves, vdeclines, vtotals);
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

  event NewProposal(address indexed _proposal, bytes32 indexed _document, uint256 indexed _budget);

  function Dao(address _config) {
    config = _config;
    owner = msg.sender;
    tokenLedger = ConfigInterface(config).getConfigAddress("ledger");
    badgeLedger = Token(tokenLedger).badgeLedger();
    proposalsCount = 0;
  }

  function propose(bytes32 _document, uint256 _weibudget) {
    if (Badge(badgeLedger).balanceOf(msg.sender) <= 0) throw;
    if (_weibudget > funds()) throw;
    address _proposal = new Proposal(config);
    proposals[_proposal].budget = _weibudget;
    proposals[_proposal].document = _document;
    proposalsCount++;
    proposalIndex[proposalsCount] = _proposal;
    NewProposal(_proposal, _document, _weibudget);
  }

  function getProposal(uint256 _index) public constant returns (address proposal) {
    return proposalIndex[_index];
  }

  function funds() public constant returns (uint256 weifunds) {
    return address(this).balance;
  }

}
