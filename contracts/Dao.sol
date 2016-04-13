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

  enum Status { Pledging, FailPledge, Voting, FailVote, Completed }

  Status public status = Status.Pledging;

  address public proposer;
  address public provider;
  address public dao;
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
    if (now < _time) {
      throw;
    } else {
      _
    }
  }

  modifier onlyBefore(uint _time) {
    if (now > _time) { 
      throw;
    } else {
      _
    }
  }

  modifier atStatus(Status _status) {
    if (_status != status) { 
      throw;
    } else {
      _
    }
  }

  function resolvePledges() onlyAfter(pledgeData.endDate) atStatus(Status.Pledging) internal returns (bool _success) {
    uint256 _totalpledges = pledgeData.totalApproves + pledgeData.totalDeclines;
    uint256 _approveppb = partsPerBillion(pledgeData.totalApproves, _totalpledges); 
    if (dissolve) {
      if (_approveppb <= 800000000) {
        status = Status.FailPledge;
      } else {
        status = Status.Voting;
      }
    } else {
      if (_approveppb <= 500000000) {
        status = Status.FailPledge;
      } else {
        status = Status.Voting;
      }
    }
    _success = true;
    return _success;
  }

  function resolvePledgeFail() onlyAfter(pledgeData.endDate) atStatus(Status.FailPledge) internal returns (bool _success) {
  }

  function resolveVotes() onlyAfter(voteData.endDate) atStatus(Status.Voting) internal returns (bool _success) {
  }

  function Proposal(address _config, address _badgeledger, address _tokenledger, bytes32 _environment, bool _dissolve) {
    proposer = tx.origin;
    dao = msg.sender;
    badgeLedger = _badgeledger;
    tokenLedger = _tokenledger;
    minPledges = ConfigInterface(_config).getConfigUint("pledges:minimum");
    minVotes = ConfigInterface(_config).getConfigUint("votes:minimum") * 1000000000;
    provider = ConfigInterface(_config).getConfigAddress("provider:address");
    pledgeData.totalApproves = 0;
    pledgeData.totalDeclines = 0;
    voteData.totalApproves = 0;
    voteData.totalDeclines = 0;
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

  function partsPerBillion(uint256 _a, uint256 _c) returns (uint256 b) {
    b = (1000000000 * _a + _c / 2) / _c;
    return b;
  }

  function calcShare(uint256 _antecedent, uint256 _consequent, uint256 _amount) returns (uint256 share) {
    uint256 _ppb = partsPerBillion(_antecedent, _consequent);
    share = ((_ppb * _amount) / 1000000000);
    return share;
  }

  function pledgeApprove(uint256 _amount) returns (bool success) {
    return pledge(true, _amount);
  }

  function pledgeDecline(uint256 _amount) returns (bool success) {
    return pledge(false, _amount);
  }

  function pledge(bool _pledge, uint256 _amount) onlyAfter(pledgeData.startDate) onlyBefore(pledgeData.endDate) internal returns (bool success) {
    if (!Badge(badgeLedger).transferFrom(msg.sender, address(this), _amount)) {
      success = false;
    } else {
      if (_pledge == true) pledgeData.totalApproves += _amount;
      if (_pledge == false) pledgeData.totalDeclines += _amount;
      pledgeData.balances[msg.sender] = _amount;
      Pledge(msg.sender, _amount, _pledge);
      success = true;
    }
    return success;
  }


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

  function voteApprove(uint256 _amount) returns (bool success) {
    return vote(true, _amount);
  }

  function voteDecline(uint256 _amount) returns (bool success) {
    return vote(false, _amount);
  }


  function vote(bool _vote, uint256 _amount) atStatus(Status.Voting) onlyAfter(voteData.startDate) onlyBefore(voteData.endDate) internal returns (bool success) {
    if (!Token(tokenLedger).transferFrom(msg.sender, address(this), _amount)) {
      success = false;
    } else {
      if (_vote == true) voteData.totalApproves += _amount;
      if (_vote == false) voteData.totalDeclines += _amount;
      voteData.balances[msg.sender] = _amount;
      Vote(msg.sender, _amount, _vote);
      success = true;
    }
    return success;
  }

  function resolve() returns (bool success) {
    return true;
  }

  function releaseBadges() onlyAfter(pledgeData.endDate) returns (bool success) {
    return true;
  }

  function releaseTokens() onlyAfter(voteData.endDate) returns (bool success) {
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

  function iPropose(bytes32 _document, uint256 _weibudget, bool _dissolve) internal returns (bool success, address proposal) {
    if (Badge(badgeLedger).balanceOf(msg.sender) <= 0) throw;
    if (_weibudget > funds()) throw;
    proposal = new Proposal(config, badgeLedger, tokenLedger, environment, _dissolve);
    proposals[proposal].budget = _weibudget;
    proposals[proposal].document = _document;
    proposalsCount++;
    proposalIndex[proposalsCount] = proposal;
    NewProposal(proposal, _document, _weibudget);
    return (true, proposal);
  }

  function propose(bytes32 _document, uint256 _weibudget) returns (bool success, address proposal) {
    if (Badge(badgeLedger).balanceOf(msg.sender) <= 0) return (false, 0x0000000000000000000000000000000000000000);
    (success, proposal) = iPropose(_document, _weibudget, false);
    if (success) {
      if (proposal.send(_weibudget)) return (success, proposal);
    } else {
      success = false;
      return (success, 0x0000000000000000000000000000000000000000);
    }
  }

  function proposeDissolve(bytes32 _document) returns (bool success, address proposal) {
    if (Badge(badgeLedger).balanceOf(msg.sender) <= 0) return (false, 0x0000000000000000000000000000000000000000);
    uint256 _weibudget = funds();
    if (success) {
      if (proposal.send(_weibudget)) return (success, proposal);
    } else {
      success = false;
      return (success, 0x0000000000000000000000000000000000000000);
    }
  }

  function getProposal(uint256 _index) public constant returns (address proposal) {
    return proposalIndex[_index];
  }

  function funds() public constant returns (uint256 weifunds) {
    return address(this).balance;
  }

}
