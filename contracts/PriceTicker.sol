

contract PriceTicker is PriceTickerInterface {

  modifier ifAdmin() { 
    if(admins[msg.sender]) _ 
  }

  function PriceTicker() {
    admins[msg.sender] = true;
  }

  function updateReq(bytes32 _symbol) returns (bool success) {
    Request(_symbol);
    return true;
  }

  function removeAdmin(address _address) ifAdmin returns (bool success) {
    admins[_address] = false;
    return true;
  }

  function setPrice(bytes32 _symbol, uint256 _bid, uint256 _ask) ifAdmin returns (bool success) {
    prices[_symbol].bid = _bid;
    prices[_symbol].ask = _ask;
    prices[_symbol].lastUpdate = block.number;
    Update(_symbol, _bid, _ask);
    return true;
  }

  function getPrice(bytes32 _symbol) public constant returns (uint256 bid, uint256 ask, uint256 lastupdate) {
    return (prices[_symbol].bid, prices[_symbol].ask, prices[_symbol].lastUpdate);
  }
}
