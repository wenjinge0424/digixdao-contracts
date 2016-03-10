// Testnet genesis.json allocator 

var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));
var accounts = web3.eth.accounts

var genesis = {
  nonce: "0x0000000000000042",
  difficulty: "0x7",
  mixhash: "0x0000000000000000000000000000000000000000000000000000000000000000",
  coinbase: "0x0000000000000000000000000000000000000000",
  timestamp: "0x00",
  parentHash: "0x0000000000000000000000000000000000000000000000000000000000000000",
  extraData: "0x11bbe8db4e347b4e8c937c1c8370e4b5ed33adb3db69cbdb7a38e1e50b1b82fa",
  gasLimit: "0x2fefd8",
  alloc: new Object()
}

accounts.forEach(function(acc) {
  account = acc.replace("0x", "");
  genesis['alloc'][account] = {balance: "170141183460469231731687303715884105728"}
});

var genesisstring = JSON.stringify(genesis, null, 4);

fs.writeFileSync("/tmp/genesis.json", genesisstring, 'utf-8');
