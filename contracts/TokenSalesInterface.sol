import "./PriceTicker.sol";

contract TokenSalesInterface {

  struct Info {
    uint256 startDate;
    uint256 endDate;
    uint256 amount;
    uint256 totalWeiSold;
    uint256 totalUsdSold;
    uint userCount;
  }

  struct Buyer {
    uint256 usdTotal;
    uint256 weiTotal;
    bool claimed;
  }

  address owner;
  Info saleInfo;
  mapping (address => Buyer) buyers;

  function permille(uint256 _a, uint256 _b) public constant returns (uint256 c);

  function calcShare(uint256 _contrib, uint256 _total) public constant returns (uint256 share);

  function purchase(address _user, uint256 _wei) returns (bool success);

  function initUser(address _user) internal returns (bool success);

  function claim(address _buyer) returns (bool success);

  function getUsdWei() public constant returns (uint);

  function userInfo(address _user) public constant returns (uint256 usdtotal, uint256 weitotal, bool claimed); 

  function totalWeiSold() public constant returns (uint);

  function totalUsdSold() public constant returns (uint);

  event Sold(address indexed _buyer, uint256 indexed _wei, uint256 indexed _usd);

}
