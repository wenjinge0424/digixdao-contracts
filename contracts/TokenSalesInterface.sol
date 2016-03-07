contract TokenSalesInterface {
  struct Info {
    uint256 startDate;
    uint256 endDate;
    uint256 amount;
    uint256 totalWeiSold;
    uint256 totalUsdSold;
  }

  Info saleInfo;

  function claim(address _buyer) returns (bool success);

  function getUsdWei() public constant returns (uint);

  function totalWeiSold() public constant returns (uint);

  function totalUsdSold() public constant returns (uint);

  event Sold(address indexed _buyer, uint256 indexed _amount, uint256 indexed _weitotal);

}
