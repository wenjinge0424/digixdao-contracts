import "./Interfaces.sol";

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
    locked = false;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return users[_owner].balance;
  }

  function badgesOf(address _owner) constant returns (uint256 badge) {
    return users[_owner].badges;
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    if (users[msg.sender].balance >= _value && _value > 0) {
      users[msg.sender].balance -= _value;
      users[_to].balance += _value;
      Transfer(msg.sender, _to, _value);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function sendBadge(address _to, uint256 _value) returns (bool success) {
    if (users[msg.sender].badges >= _value && _value > 0) {
      users[msg.sender].badges -= _value;
      users[_to].badges += _value;
      Transfer(msg.sender, _to, _value);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    if (users[_from].balance >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      users[_to].balance += _value;
      users[_from].balance -= _value;
      allowed[_from][msg.sender] -= _value;
      Transfer(_from, _to, _value);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  function mint(address _owner, uint256 _amount) ifSales returns (bool success) {
    totalSupply += _amount;
    users[_owner].balance += _amount;
    return true;
  }

  function mintBadge(address _owner, uint256 _amount) ifSales returns (bool success) {
    totalBadges += _amount;
    users[_owner].badges += _amount;
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
