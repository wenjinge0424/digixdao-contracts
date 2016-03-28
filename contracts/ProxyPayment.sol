import "./Interfaces.sol";

contract ProxyPayment {

  address payout;
  address tokenSales; 
  address owner;

  function ProxyPayment(address _payout, address _tokenSales) {
    if (!TokenSalesInterface(_tokenSales).regProxy(address(this), _payout)) throw;
    payout = _payout;
    tokenSales = _tokenSales;
  }

  function () {
    if (!TokenSalesInterface(tokenSales).proxyPurchase.value(msg.value)(address(this))) throw;
  }
}
