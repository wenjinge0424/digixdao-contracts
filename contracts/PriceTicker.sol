contract PriceTicker {

  address public owner;
  uint256 public ethusd;

  modifier ifOwner() { 
    if(msg.sender == owner) _ 
  }

  function PriceTicker() {
    owner = msg.sender;
    ethusd = 0;
  }

  function setPrice(uint256 _price) ifOwner returns (bool success) {
    ethusd = _price; 
    return true;
  }

}
