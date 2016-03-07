var Web3 = require('web3');
var web3 = new Web3();
var fs = require('fs');
var config = require('./env.js');

web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

var contractbase = config.contractBase();
var buildbase = config.buildBase();

var cfile = "";

var contracts = ["TokenInterface.sol", "Token.sol"];

contracts.forEach(function(contract) {
  var contractfile = contractbase + contract 
  var content = fs.readFileSync(contractfile, 'utf-8');
  cfile = cfile.concat(content);
});

var compiled = web3.eth.compile.solidity(cfile);
var compiled_file = buildbase + "app.js";
var app_file = "";
app_file = app_file.concat("module.exports = {\n");
app_file = app_file.concat("contracts: " + JSON.stringify(compiled, 2, null));
app_file = app_file.concat("\n};");

fs.writeFileSync(compiled_file, app_file);
