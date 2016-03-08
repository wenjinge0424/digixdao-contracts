import "./TokenSalesInterface.sol";

contract TokenSales is TokenSalesInterface {

  modifier ifOwner() {
    if (msg.sender != owner)
      throw;
    _
  }

  function TokenSales(uint256 _startDate, uint256 _endDate, uint256 _amount) {
    saleInfo.startDate = _startDate;
    saleInfo.endDate = _endDate;
    saleInfo.amount = _amount * 1000000000;
    saleInfo.totalWeiSold = 0;
    saleInfo.totalUsdSold = 0;
    owner = msg.sender;
  }

  function () {
    saleInfo.totalWeiSold += msg.value;
  }

  function permille(uint256 _a, uint256 _b) public constant returns (uint256 mille) {
    mille = (1000000000 * _a + _b / 2) / _b;
    return mille;
  }

  function calcShare(uint256 _contrib, uint256 _total) public constant returns (uint256 share) {
    uint256 _mille = permille(_contrib, _total);
    share = _mille * saleInfo.amount / 1000000000;
    return share;
  }

  function purchase(address _user, uint256 _wei) returns (bool success) {
    
  }

  function initUser(address _buyer) internal returns (bool success) {
    success = true;
    return success;
  }

  function claim(address _buyer) returns (bool success) {
    success = true;
    return success;
  }

  function getUsdWei() public constant returns (uint) {
    /*USDOracle oracle = USDOracle(0x1c68f4f35ac5239650333d291e6ce7f841149937);*/
    return 31337;
  }

  function userInfo(address _user) public constant returns (uint256 usdtotal, uint256 weitotal, bool claimed) {
    return (buyers[_user].usdTotal, buyers[_user].weiTotal, buyers[_user].claimed);
  }


  function totalWeiSold() public constant returns (uint) {
    return saleInfo.totalWeiSold;
  }

  function totalUsdSold() public constant returns (uint) {
    return saleInfo.totalUsdSold;
  }
  
}
