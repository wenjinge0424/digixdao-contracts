import "./Interfaces.sol";

// DigixDAO Crowdsale Round 1
// https://sale.digix.io

contract TokenSales is TokenSalesInterface {

  modifier ifOwner() {
    if (msg.sender != owner)
      throw;
    _
  }

  uint256 public WEI_PER_ETH = 1000000000000000000;
  uint256 public MILLE = 1000000000;

  function TokenSales(address _config) {
    owner = msg.sender;
    config = _config;
    saleInfo.startDate = ConfigInterface(_config).getConfigUint("sale1:period1");
    saleInfo.periodTwo = ConfigInterface(_config).getConfigUint("sale1:period2");
    saleInfo.periodThree = ConfigInterface(_config).getConfigUint("sale1:period3");
    saleInfo.endDate = ConfigInterface(_config).getConfigUint("sale1:end");
    saleInfo.amount = 1700000 * MILLE;
    saleInfo.totalWei = 0;
    saleInfo.totalCents = 0;
    saleInfo.goal = 50000000;
  }

  function () {
    if (!purchase(msg.sender)) {
      throw;
    }
  }

  function purchase(address _user) returns (bool success) {
    uint256 _cents = weiToCents(msg.value);
    uint256 _wei = msg.value;
    uint256 _modifier;
    uint _period = getPeriod();
    if ((_period == 0) || (_cents == 0)) {
      success = false;
    } else {
      if (_period == 3) _modifier = 100;
      if (_period == 2) _modifier = 115;
      if (_period == 1) _modifier = 130;
      uint256 _creditwei = msg.value;
      uint256 _creditcents = (weiToCents(_creditwei) * _modifier * 10000) / 1000000 ;
      buyers[_user].centsTotal += _creditcents;
      buyers[_user].weiTotal += _creditwei; 
      saleInfo.totalCents += _creditcents;
      saleInfo.totalWei += _creditwei;
      Purchase(ethToCents, _modifier, _creditcents); 
      success = true;
    }
    return success;
  }

  function permille(uint256 _a, uint256 _b) public constant returns (uint256 mille) {
    mille = (MILLE * _a + _b / 2) / _b;
    return mille;
  }

  function calcShare(uint256 _contrib, uint256 _total) public constant returns (uint256 share) {
    uint256 _mille = permille(_contrib, _total);
    share = ((_mille * saleInfo.amount) / MILLE);
    return share;
  }

  function weiToCents(uint256 _wei) public constant returns (uint256 centsvalue) {
    centsvalue = ((_wei * 100000 / WEI_PER_ETH) * ethToCents) / 100000;
    return centsvalue;
  }

  function setEthToCents(uint256 _eth) ifOwner returns (bool success) {
    ethToCents = _eth;
    success = true;
    return success;
  }

  function getSaleInfo() public constant returns (uint256 startsale, uint256 two, uint256 three, uint256 endsale, uint256 totalwei, uint256 totalcents) {
    startsale = saleInfo.startDate;
    two = saleInfo.periodTwo;
    three = saleInfo.periodThree;
    endsale = saleInfo.endDate;
    totalwei = saleInfo.totalWei;
    totalcents = saleInfo.totalCents;
  }

  function goalReached() public constant returns (bool reached) {
    reached = saleInfo.totalCents >= saleInfo.goal;
    return reached;
  }

  function claim() returns (bool success) {
    if ( (now < saleInfo.endDate) || (buyers[msg.sender].claimed == true) ) {
      return false;
    }
  
    if (!goalReached()) {
      if (!address(msg.sender).send(buyers[msg.sender].weiTotal)) throw;
      buyers[msg.sender].claimed = true;
      return false;
    }

    if (goalReached()) {
      buyers[msg.sender].claimed = true;
      address _tokenc = ConfigInterface(config).getConfigAddress("ledger");
      uint256 _tokens = calcShare(buyers[msg.sender].centsTotal, saleInfo.totalCents); 
      TokenInterface(_tokenc).mint(msg.sender, _tokens);
      return success;
    }
  }

  function release() returns (bool success) {
    if (now < saleInfo.endDate) {
      success = false;
      return success;
    }
    if (!goalReached()) {

    }
  }

  function getPeriod() public constant returns (uint saleperiod) {
    if ((now > saleInfo.endDate) || (now < saleInfo.startDate)) {
      saleperiod = 0;
      return saleperiod;
    }
    if (now >= saleInfo.periodThree) {
      saleperiod = 3;
      return saleperiod;
    }
    if (now >= saleInfo.periodTwo) {
      saleperiod = 2;
      return saleperiod;
    }
    if (now < saleInfo.periodTwo) {
      saleperiod = 1;
      return saleperiod;
    }
  }

  function userInfo(address _user) public constant returns (uint256 centstotal, uint256 weitotal, uint256 share, uint badges, bool claimed) {
    share = calcShare(buyers[_user].centsTotal, saleInfo.totalCents);
    badges = buyers[_user].centsTotal / 1500000;
    return (buyers[_user].centsTotal, buyers[_user].weiTotal, share, badges, buyers[_user].claimed);
  }


  function totalWei() public constant returns (uint) {
    return saleInfo.totalWei;
  }

  function totalCents() public constant returns (uint) {
    return saleInfo.totalCents;
  }
  
}
