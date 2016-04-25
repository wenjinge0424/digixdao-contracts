import "./Interfaces.sol";

contract Badge  {
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;

  address public owner;
  bool public locked;

  /// @return total amount of tokens
  uint256 public totalSupply;

  modifier ifOwner() {
    if (msg.sender != owner) {
      throw;
    } else {
      _
    }
  }


  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Mint(address indexed _recipient, uint256 indexed _amount);
  event Approval(address indexed _owner, address indexed _spender, uint256  _value);

  function Badge() {
    owner = msg.sender;
  }

  function safeToAdd(uint a, uint b) returns (bool) {
    return (a + b >= a);
  }

  function addSafely(uint a, uint b) returns (uint result) {
    if (!safeToAdd(a, b)) {
      throw;
    } else {
      result = a + b;
      return result;
    }
  }

  function safeToSubtract(uint a, uint b) returns (bool) {
    return (b <= a);
  }

  function subtractSafely(uint a, uint b) returns (uint) {
    if (!safeToSubtract(a, b)) throw;
    return a - b;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] = subtractSafely(balances[msg.sender], _value);
      balances[_to] = addSafely(_value, balances[_to]);
      Transfer(msg.sender, _to, _value);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      balances[_to] = addSafely(balances[_to], _value);
      balances[_from] = subtractSafely(balances[_from], _value);
      allowed[_from][msg.sender] = subtractSafely(allowed[_from][msg.sender], _value);
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
    totalSupply = addSafely(totalSupply, _amount);
    balances[_owner] = addSafely(balances[_owner], _amount);
    Mint(_owner, _amount);
    return true;
  }

  function setOwner(address _owner) ifOwner returns (bool success) {
    owner = _owner;
    return true;
  }

}

contract Token {

  address public owner;
  address public config;
  bool public locked;
  address public dao;
  address public badgeLedger;
  uint256 public totalSupply;

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  mapping (address => bool) seller;

  /// @return total amount of tokens

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

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Mint(address indexed _recipient, uint256  _amount);
  event Approval(address indexed _owner, address indexed _spender, uint256  _value);

  function Token(address _config) {
    config = _config;
    owner = msg.sender;
    address _initseller = ConfigInterface(_config).getConfigAddress("sale1:address");
    seller[_initseller] = true; 
    badgeLedger = new Badge();
    locked = false;
  }

  function safeToAdd(uint a, uint b) returns (bool) {
    return (a + b >= a);
  }

  function addSafely(uint a, uint b) returns (uint result) {
    if (!safeToAdd(a, b)) {
      throw;
    } else {
      result = a + b;
      return result;
    }
  }

  function safeToSubtract(uint a, uint b) returns (bool) {
    return (b <= a);
  }

  function subtractSafely(uint a, uint b) returns (uint) {
    if (!safeToSubtract(a, b)) throw;
    return a - b;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] = subtractSafely(balances[msg.sender], _value);
      balances[_to] = addSafely(balances[_to], _value);
      Transfer(msg.sender, _to, _value);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      balances[_to] = addSafely(balances[_to], _value);
      balances[_from] = subtractSafely(balances[_from], _value);
      allowed[_from][msg.sender] = subtractSafely(allowed[_from][msg.sender], _value);
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
    totalSupply = addSafely(_amount, totalSupply);
    balances[_owner] = addSafely(balances[_owner], _amount);
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

  function setDao(address _newdao) ifDao returns (bool success) {
    dao = _newdao;
    return true;
  }

  function isSeller(address _query) returns (bool isseller) {
    return seller[_query];
  }

  function registerSeller(address _tokensales) ifDao returns (bool success) {
    seller[_tokensales] = true;
    return true;
  }

  function unregisterSeller(address _tokensales) ifDao returns (bool success) {
    seller[_tokensales] = false;
    return true;
  }

  function setOwner(address _newowner) ifDao returns (bool success) {
    if(Badge(badgeLedger).setOwner(_newowner)) {
      owner = _newowner;
      success = true;
    } else {
      success = false;
    }
    return success;
  }

}
