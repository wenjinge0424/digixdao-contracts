import "./Interfaces.sol";

contract Config is ConfigInterface {

  event ConfigChange(bytes32 indexed _configKey, address indexed _user);

  modifier ifAdmin() {
    if ((msg.sender != owner) || (admins[msg.sender] == false)) throw;
    _
  }

  modifier ifOwner() {
    if (msg.sender != owner) throw;
    _
  }

  function Config() {
    owner = msg.sender;
  }

  function setConfigAddress(bytes32 _key, address _val) ifAdmin returns (bool success) {
    addressMap[_key] = _val;
    return true;
  }

  function setConfigBool(bytes32 _key, bool _val) ifAdmin returns (bool success) {
    boolMap[_key] = _val;
    return true;
  }

  function setConfigBytes(bytes32 _key, bytes32 _val) ifAdmin returns (bool success) {
    bytesMap[_key] = _val;
    return true;
  }

  function setConfigUint(bytes32 _key, uint256 _val) ifAdmin returns (bool success) {
    uintMap[_key] = _val;
    return true;
  }

  function getConfigAddress(bytes32 _key) returns (address val) {
    val = addressMap[_key];
    return val;
  }

  function getConfigBool(bytes32 _key) returns (bool val) {
    val = boolMap[_key];
    return val;
  }

  function getConfigBytes(bytes32 _key) returns (bytes32 val) {
    val = bytesMap[_key];
    return val;
  }

  function getConfigUint(bytes32 _key) returns (uint256 val) {
    val = uintMap[_key];
    return val;
  }

  function addAdmin(address _admin) ifOwner returns (bool success) {
    admins[_admin] = true;
    return true;
  }

  function removeAdmin(address _admin) ifOwner returns (bool success) {
    admins[_admin] = false;
    return true;
  }
}
