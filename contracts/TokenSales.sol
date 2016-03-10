import "./TokenSalesInterface.sol";
import "./TokenInterface.sol";

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
  uint256 public DGD_TOTAL = 1700000;

  function TokenSales(uint256 _start, uint256 _end, uint256 _ptwo, uint256 _pthree) {
    saleInfo.startDate = _start;
    saleInfo.periodTwo = _ptwo;
    saleInfo.periodThree = _pthree;
    saleInfo.endDate = _end;
    saleInfo.amount = DGD_TOTAL * MILLE;
    saleInfo.totalWei = 0;
    saleInfo.totalCents = 0;
    owner = msg.sender;
  }

  function () {
    if (!purchase(msg.sender)) {
      throw;
    }
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

  function getSaleInfo() public constant returns (uint256 startsale, uint256 two, uint256 three, uint256 endsale, uint256 totalwei, uint256 totalcents) {
    startsale = saleInfo.startDate;
    two = saleInfo.periodTwo;
    three = saleInfo.periodThree;
    endsale = saleInfo.endDate;
    totalwei = saleInfo.totalWei;
    totalcents = saleInfo.totalCents;
  }


  function claim() returns (bool success) {
    bool _claimed = buyers[msg.sender].claimed;
    if ((now < saleInfo.endDate) || (_claimed)) {
      success = false;
    } else {
      success = true;
    }
    return success;
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
