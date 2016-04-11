import "./Interfaces.sol";

contract Badge  {
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  mapping (address => bool) seller;

  address owner;
  bool locked;

  /// @return total amount of tokens
  uint256 public totalSupply;

  modifier ifOwner() {
    if (msg.sender != owner) throw;
    _
  }

  event Transfer(address indexed _from, address indexed _to, uint256 indexed _value);
  event Mint(address indexed _recipient, uint256 indexed _amount);
  event Approval(address indexed _owner, address indexed _spender, uint256 indexed _value);

  function Badge(address _config) {
    owner = msg.sender;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      balances[_to] += _value;
      balances[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      Transfer(_from, _to, _value);
      return true;
    } else {
      return false;
    }
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    success = true;
    return success;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    remaining = allowed[_owner][_spender];
    return remaining;
  }

  function mint(address _owner, uint256 _amount) ifOwner returns (bool success) {
    totalSupply += _amount;
    balances[_owner] += _amount;
    Mint(_owner, _amount);
    return true;
  }

}

contract Token is TokenInterface {

  modifier noEther() {
    if (msg.value > 0) throw;
    _
  }

  modifier ifSales() {
    if (!seller[msg.sender]) throw; 
    _ 
  }

  modifier ifOwner() {
    if (msg.sender != owner) throw;
    _
  }

  modifier ifDao() {
    if (msg.sender != dao) throw;
    _
  }

  function Token(address _config) {
    config = _config;
    owner = msg.sender;
    address _initseller = ConfigInterface(_config).getConfigAddress("sale1:address");
    seller[_initseller] = true; 
    badgeLedger = new Badge(_config);
    locked = false;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      balances[_to] += _value;
      balances[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      Transfer(_from, _to, _value);
      return true;
    } else {
      return false;
    }
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    success = true;
    return success;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    remaining = allowed[_owner][_spender];
    return remaining;
  }
  function mint(address _owner, uint256 _amount) ifSales returns (bool success) {
    totalSupply += _amount;
    balances[_owner] += _amount;
    return true;
  }

  function mintBadge(address _owner, uint256 _amount) ifSales returns (bool success) {
    if (!Badge(badgeLedger).mint(_owner, _amount)) return false;
    return true;
  }

  function registerDao(address _dao) ifOwner returns (bool success) {
    if (locked == true) return false;
    dao = _dao;
    locked = true;
    return true;
  }

  function registerSeller(address _tokensales) ifDao returns (bool success) {
    seller[_tokensales] = true;
    return true;
  }
}
