import "./PriceTicker.sol";

contract TokenSalesInterface {

  struct Info {
    uint256 startDate;
    uint256 endDate;
    uint256 periodTwo;
    uint256 periodThree;
    uint256 totalWei;
    uint256 totalCents;
    uint256 amount;
  }

  struct Buyer {
    uint256 centsTotal;
    uint256 weiTotal;
    bool claimed;
  }

  address public owner;
  Info saleInfo;
  uint256 public ethToCents;
  mapping (address => Buyer) buyers;
  uint256 public periodTwo;
  uint256 public periodThree;

  function permille(uint256 _a, uint256 _b) public constant returns (uint256 c);

  function calcShare(uint256 _contrib, uint256 _total) public constant returns (uint256 share);

  function weiToCents(uint256 _wei) public constant returns (uint256 centsvalue);

  function purchase(address _user) returns (bool success);

  function userInfo(address _user) public constant returns (uint256 centstotal, uint256 weitotal, uint256 share, bool claimed); 

  function totalWei() public constant returns (uint);

  function totalCents() public constant returns (uint);

  function getSaleInfo() public constant returns (uint256 startsale, uint256 two, uint256 three, uint256 endsale, uint256 totalwei, uint256 totalcents);

  function claim() returns (bool success);

  function getPeriod() public constant returns (uint saleperiod);

  event Purchase(uint256 indexed _exchange, uint256 indexed _rate, uint256 indexed _cents);
  event Claim(address indexed _user, uint256 indexed _amount);

}
