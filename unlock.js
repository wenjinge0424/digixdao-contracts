var password = "DIGIXTESTER123"

eth.accounts.forEach(function(account) {
  personal.unlockAccount(account, password, 31536000);
  console.log("Unlocked " + account);
});

console.log("Testnet ready");

