var password = "DIGIXTESTER123"

eth.accounts.forEach(function(account) {
  personal.unlockAccount(account, password);
});
