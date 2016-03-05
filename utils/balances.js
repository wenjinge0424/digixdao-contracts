// Balance checker

var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

web3.eth.accounts.forEach(function(account) {
  var balance = web3.eth.getBalance(account);
  var ether = web3.fromWei(balance, 'ether');
  console.log("Account: " + account + " Balance: " + balance);
});
