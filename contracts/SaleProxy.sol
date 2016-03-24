import "./Interfaces.sol";

contract SaleProxy is SaleProxyInterface {

  function SaleProxy(address _payout, address _tokensales) {
    payoutAddress = _payout;
    tokenSales = _tokensales;
  }

  function () {
    if (!TokenSalesInterface(tokenSales).purchase(payoutAddress)) throw;
  }
}
