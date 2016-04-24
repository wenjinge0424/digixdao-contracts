import "./Token.sol";
import "./Interfaces.sol";

contract Collector {
  address public owner;
  address public dgdTokens;
  address public txFeePool;
  uint256 public payoutPeriod;

  modifier ifTxFeePool() {
    if (msg.sender != txFeePool) {
      throw;
    } else {
      _
    }
  }

  function Collector(address _owner, address _dgdtokens, uint256 _payoutperiod) {
    owner = _owner;
    dgdTokens = _dgdtokens;
    txFeePool = msg.sender;
    payoutPeriod = _payoutperiod;
  }

  function collect() ifTxFeePool returns (bool _success) {
    _success = true;
    return _success;
  }

  function withdraw() ifTxFeePool returns (bool _success) {
    _success = true;
    return _success;
  }
}

contract GoldTxFeePool {

  struct Period {
    uint256 collectionStart;
    uint256 collectionEnd;
    mapping(address => address) collectors;
  }

  address public dgxTokens;
  address public dgdTokens;
  bytes32 public environment;
  uint256 public collectionDuration;
  uint256 public periodLength;
  uint256 public periodCount;
  mapping (uint256 => Period) periods;

  modifier afterRecent() {
    if (now < periods[periodCount].collectionEnd) {
      throw;
    } else {
      _
    }
  }

  function GoldTxFeePool(address _dgxTokens, address _dgdTokens, bytes32 _environment) {
    dgxTokens = _dgxTokens;
    dgdTokens = _dgdTokens;
    environment = _environment;
    periodCount = 1;

    if (environment == "testnet") {
      collectionDuration = 5 minutes;
      periodLength = 10 minutes;
    }
    if (environment == "morden") {
      collectionDuration = 10 minutes; 
      periodLength = 30 minutes;
    } 
    if (environment == "mainnet") {
      collectionDuration = 7 days;
      periodLength = 90 days;
    }
    periods[periodCount].collectionStart = now + periodLength;
    periods[periodCount].collectionEnd = periods[periodCount].collectionStart + collectionDuration;
  }

  function newPeriod() afterRecent returns (bool _success) {
    uint256 _newstart = periods[periodCount].collectionStart + periodLength;
    uint256 _newend = periods[periodCount].collectionEnd + periodLength;
    periodCount++;
    periods[periodCount].collectionStart = _newstart;
    periods[periodCount].collectionEnd = _newend;
    _success = true;
    return _success;
  }

  function getPeriodInfo() returns (uint256 _start, uint256 _end) {
    _start = periods[periodCount].collectionStart;
    _end = periods[periodCount].collectionEnd;
    return (_start, _end);
  }

  function collect() {
  }

  function withdraw() {
  }
}
