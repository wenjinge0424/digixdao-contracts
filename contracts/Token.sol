import "./TokenInterface.sol";
import "./DAOInterface.sol";

contract Token is TokenInterface {

  modifier noEther() {
    if (msg.value > 0) throw;
    _
  }

  modifier ifDao() {
    if (msg.sender != dao) throw;
    _
  }

  modifier ifSales() {
    if (!seller[msg.sender]) 
      throw; 
    _ 
  }

  function mint(address _owner, uint256 _amount) ifSales returns (bool success) {
    totalSupply += _amount;
    balances[_owner] += _amount;
    return success;
  }

  function Token(address _initseller) {
    seller[_initseller] = true; 
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

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }


  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}
