contract TokenSales is TokenSalesInterface {

  function TokenSales(uint256 _startDate, uint256 _endDate, uint256 _amount) {
    saleInfo.startDate = _startDate;
    saleInfo.endDate = _endDate;
    saleInfo.amount = _amount * 10000;
    saleInfo.totalWeiSold = 0;
    saleInfo.totalUsdSold = 0;
  }

  function () {
    saleInfo.totalWeiSold += msg.value;
  }

  function claim(address _buyer) returns (bool success) {
    success = true;
    return success;
  }

  function getUsdWei() public constant returns (uint) {
    /*USDOracle oracle = USDOracle(0x1c68f4f35ac5239650333d291e6ce7f841149937);*/
    
    return 31337;
  }

  function totalWeiSold() public constant returns (uint) {
    return saleInfo.totalWeiSold;
  }

  function totalUsdSold() public constant returns (uint) {
    return saleInfo.totalUsdSold;
  }
  
}
