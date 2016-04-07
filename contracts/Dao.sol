import "./Token.sol";
import "./Interfaces.sol";

contract Proposal {

  address public config;
  address public proposer;

}

contract Dao {
  
  address public config;
  address public owner;
  address public tokenLedger;
  address public badgeLedger;

  function Dao(address _config) {
    config = _config;
    owner = msg.sender;
    tokenLedger = ConfigInterface(config).getConfigAddress("ledger");
    badgeLedger = Token(tokenLedger).badgeLedger();
  }
  

}
