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
  PledgeData pledgedata;
  VoteData votedata;
  uint8 public status;

  function Proposal(address _config) {
    proposer = tx.origin;
    minPledges = ConfigInterface(_config).getConfigUint("pledges:minimum");
    minVotes = ConfigInterface(_config).getConfigUint("votes:minimum") * 1000000000;
    provider = ConfigInterface(_config).getConfigAddress("provider:address");
  }

  function pledge(bool _pledge, uint256 _amount) returns (bool success) {
    uint256 _allowance = Badge(badgeLedger).allowance(msg.sender, address(this));
    if (_allowance <= 0) return false;
    if (!Badge(badgeLedger).transferFrom(msg.sender, address(this), _allowance)) return false;
    pledgedata.balances[msg.sender] = _allowance;
    if (_pledge == true) {
      pledgedata.totalApproves++;
    } else {
      pledgedata.totalDeclines++;
    }
    return true;
  }

  function vote(bool _vote) returns (bool success) {
  }

  function resolve() returns (bool success) {
  }

  function releaseBadges() {
  }

  function releaseTokens() {
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

  event NewProposal(address indexed _proposal, bytes32 indexed _document, uint256 indexed _budget);

  function Dao(address _config) {
    config = _config;
    owner = msg.sender;
    tokenLedger = ConfigInterface(config).getConfigAddress("ledger");
    badgeLedger = Token(tokenLedger).badgeLedger();
  }

  function propose(bytes32 _document, uint256 _weibudget) {
    if (Badge(badgeLedger).balanceOf(msg.sender) <= 0) throw;
    if (_weibudget > funds()) throw;
    address _proposal = new Proposal(config);
    proposals[_proposal].budget = _weibudget;
    proposals[_proposal].document = _document;
    NewProposal(_proposal, _document, _weibudget);
  }

  function funds() public constant returns (uint256 weifunds) {
    return address(this).balance;
  }

}
