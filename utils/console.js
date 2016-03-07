Web3 = require('web3');
web3 = new Web3();
app = require('../build/app.js');
deployConfig = require('../build/deploy_config.js');
Pudding = require("ether-pudding");
Pudding.setWeb3(web3);
web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

Token = Pudding.whisk({abi: app.contracts.Token.info.abiDefinition, binary: app.contracts.Token.code});
TokenSales = Pudding.whisk({abi: app.contracts.TokenSales.info.abiDefinition, binary: app.contracts.TokenSales.code});
PriceTicker = Pudding.whisk({abi: app.contracts.PriceTicker.info.abiDefinition, binary: app.contracts.PriceTicker});


var repl = require("repl")
r = repl.start("digixdao> ")
