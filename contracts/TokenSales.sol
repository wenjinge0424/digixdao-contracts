import "./Interfaces.sol";

contract ProxyPayment {

  address payout;
  address tokenSales; 
  address owner;

  function ProxyPayment(address _payout, address _tokenSales) {
    payout = _payout;
    tokenSales = _tokenSales;
    owner = _payout;
  }

  function () {
    if (!TokenSalesInterface(tokenSales).proxyPurchase.value(msg.value).gas(106000)(payout)) throw;
  }

}

contract TokenSales is TokenSalesInterface {

  modifier ifOwner() {
    if (msg.sender != owner) throw;
    _
  }

  modifier ifOOrigin() {
    if (tx.origin != owner) throw;
    _
  }

  mapping (address => address) proxyPayouts;
  uint256 public WEI_PER_ETH = 1000000000000000000;
  uint256 public BILLION = 1000000000;
  uint256 public CENTS = 100;


  function TokenSales(address _config) {
    owner = msg.sender;
    config = _config;
    saleStatus.founderClaim = false;
    saleStatus.releasedTokens = 0;
    saleStatus.releasedBadges = 0;
    saleStatus.claimers = 0;
    saleConfig.startDate = ConfigInterface(_config).getConfigUint("sale1:period1");
    saleConfig.periodTwo = ConfigInterface(_config).getConfigUint("sale1:period2");
    saleConfig.periodThree = ConfigInterface(_config).getConfigUint("sale1:period3");
    saleConfig.endDate = ConfigInterface(_config).getConfigUint("sale1:end");
    saleConfig.founderAmount = ConfigInterface(_config).getConfigUint("sale1:famount") * BILLION;
    saleConfig.founderWallet = ConfigInterface(_config).getConfigAddress("sale1:fwallet");
    saleConfig.goal = ConfigInterface(_config).getConfigUint("sale1:goal") * CENTS;
    saleConfig.cap = ConfigInterface(_config).getConfigUint("sale1:cap") * CENTS;
    saleInfo.amount = ConfigInterface(_config).getConfigUint("sale1:amount") * BILLION;
    saleInfo.totalWei = 0;
    saleInfo.totalCents = 0;
    saleInfo.realCents;
    saleStatus.founderClaim = false;
    locked = true;
  }

  function () {
    if (getPeriod() == 0) throw;
    uint256 _amount = msg.value;
    address _sender;
    if (proxies[msg.sender].isProxy == true) {
      _sender = proxies[msg.sender].payout;
    } else {
      _sender = msg.sender;
    }
    if (!purchase(_sender, _amount)) throw;
  }

  function proxyPurchase(address _user) returns (bool success) {
    return purchase(_user, msg.value);
  }

  function purchase(address _user, uint256 _amount) private returns (bool success) {
    uint256 _cents = weiToCents(_amount);
    if ((saleInfo.realCents + _cents) > saleConfig.cap) return false;
    uint256 _wei = _amount;
    uint256 _modifier;
    uint _period = getPeriod();
    if ((_period == 0) || (_cents == 0)) {
      return false;
    } else {
      if (_period == 3) _modifier = 100;
      if (_period == 2) _modifier = 115;
      if (_period == 1) _modifier = 130;
      uint256 _creditwei = _amount;
      uint256 _creditcents = (weiToCents(_creditwei) * _modifier * 10000) / 1000000 ;
      buyers[_user].centsTotal += _creditcents;
      buyers[_user].weiTotal += _creditwei; 
      saleInfo.totalCents += _creditcents;
      saleInfo.realCents += _cents;
      saleInfo.totalWei += _creditwei;
      Purchase(ethToCents, _modifier, _creditcents); 
      return true;
    }
  }

  function ppb(uint256 _a, uint256 _c) public constant returns (uint256 b) {
    b = (BILLION * _a + _c / 2) / _c;
    return b;
  }

  function calcShare(uint256 _contrib, uint256 _total) public constant returns (uint256 share) {
    uint256 _ppb = ppb(_contrib, _total);
    share = ((_ppb * saleInfo.amount) / BILLION);
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


  function getSaleStatus() public constant returns (bool fclaim, uint256 reltokens, uint256 relbadges, uint256 claimers) {
    return (saleStatus.founderClaim, saleStatus.releasedTokens, saleStatus.releasedBadges, saleStatus.claimers);
  }

  function getSaleInfo() public constant returns (uint256 weiamount, uint256 cents, uint256 realcents, uint256 amount) {
    return (saleInfo.totalWei, saleInfo.totalCents, saleInfo.realCents, saleInfo.amount);
  }


  function getSaleConfig() public constant returns (uint256 start, uint256 two, uint256 three, uint256 end, uint256 goal, uint256 cap, uint256 famount, address fwallet) {
    return (saleConfig.startDate, saleConfig.periodTwo, saleConfig.periodThree, saleConfig.endDate, saleConfig.goal, saleConfig.cap, saleConfig.founderAmount, saleConfig.founderWallet);
  }

  function goalReached() public constant returns (bool reached) {
    reached = (saleInfo.totalCents >= saleConfig.goal);
    return reached;
  }

  function claim() returns (bool success) {
    return claimFor(msg.sender);
  }

  function claimFor(address _user) returns (bool success) {
    if ( (now < saleConfig.endDate) || (buyers[_user].claimed == true) ) {
      return true;
    }
  
    if (!goalReached()) {
      if (!address(_user).send(buyers[_user].weiTotal)) throw;
      buyers[_user].claimed = true;
      return true;
    }

    if (goalReached()) {
      address _tokenc = ConfigInterface(config).getConfigAddress("ledger");
      uint256 _tokens = calcShare(buyers[_user].centsTotal, saleInfo.totalCents); 
      uint256 _badges = buyers[_user].centsTotal / 1500000;
      if ((TokenInterface(_tokenc).mint(msg.sender, _tokens)) && (TokenInterface(_tokenc).mintBadge(_user, _badges))) {
        saleStatus.releasedTokens += _tokens;
        saleStatus.releasedBadges += _badges;
        saleStatus.claimers += 1;
        buyers[_user].claimed = true;
        Claim(_user, _tokens, _badges);
        return true;
      } else {
        return false;
      }
    }

  }

  function claimFounders() returns (bool success) {
    if (saleStatus.founderClaim == true) return false;
    if (now < saleConfig.endDate) return false;
    if (!goalReached()) return false;
    address _tokenc = ConfigInterface(config).getConfigAddress("ledger");
    uint256 _tokens = saleConfig.founderAmount;
    uint256 _badges = 4;
    address _faddr = saleConfig.founderWallet;
    if ((TokenInterface(_tokenc).mint(_faddr, _tokens)) && (TokenInterface(_tokenc).mintBadge(_faddr, _badges))) {
      saleStatus.founderClaim = true;
      saleStatus.releasedTokens += _tokens;
      saleStatus.releasedBadges += _badges;
      saleStatus.claimers += 1;
      Claim(_faddr, _tokens, _badges);
      return true;
    } else {
      return false;
    }
  }

  function getPeriod() public constant returns (uint saleperiod) {
    if ((now > saleConfig.endDate) || (now < saleConfig.startDate)) {
      saleperiod = 0;
      return saleperiod;
    }
    if (now >= saleConfig.periodThree) {
      saleperiod = 3;
      return saleperiod;
    }
    if (now >= saleConfig.periodTwo) {
      saleperiod = 2;
      return saleperiod;
    }
    if (now < saleConfig.periodTwo) {
      saleperiod = 1;
      return saleperiod;
    }
  }

  function userInfo(address _user) public constant returns (uint256 centstotal, uint256 weitotal, uint256 share, uint badges, bool claimed) {
    share = calcShare(buyers[_user].centsTotal, saleInfo.totalCents);
    badges = buyers[_user].centsTotal / 1500000;
    return (buyers[_user].centsTotal, buyers[_user].weiTotal, share, badges, buyers[_user].claimed);
  }

  function myInfo() public constant returns (uint256 centstotal, uint256 weitotal, uint256 share, uint badges, bool claimed) {
    return userInfo(msg.sender);
  }

  function totalWei() public constant returns (uint) {
    return saleInfo.totalWei;
  }

  function totalCents() public constant returns (uint) {
    return saleInfo.totalCents;
  }

  function startDate() public constant returns (uint date) {
    return saleConfig.startDate;
  }
  
  function periodTwo() public constant returns (uint date) {
    return saleConfig.periodTwo;
  }

  function periodThree() public constant returns (uint date) {
    return saleConfig.periodThree;
  }

  function endDate() public constant returns (uint date) {
    return saleConfig.endDate;
  }

  function isEnded() public constant returns (bool ended) {
    return (now >= endDate());
  }
  
  function sendFunds() public returns (bool success) {
    if (locked) return false;
    if (!goalReached()) return false;
    if (!isEnded()) return false;
    address _dao = ConfigInterface(config).getConfigAddress("sale1:dao");
    if (_dao == 0x0000000000000000000000000000000000000000) return false;
    return _dao.send(totalWei());
  }

  function regProxy(address _payout) ifOOrigin returns (bool success) {
    address _proxy = new ProxyPayment(_payout, address(this));
    proxies[_proxy].payout = _payout;
    proxies[_proxy].isProxy = true;
    proxyPayouts[_payout] = _proxy;
    return true;
  }
  
  function getProxy(address _payout) public returns (address proxy) {
    return proxyPayouts[_payout];
  }

  function getPayout(address _proxy) public returns (address payout, bool isproxy) {
    return (proxies[_proxy].payout, proxies[_proxy].isProxy);
  }

  function unlock() ifOwner public returns (bool success) {
    locked = false;
    return true;
  }
}
