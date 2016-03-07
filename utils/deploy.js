var app = require('../build/app.js');
var env = require('../utils/env.js');
var fs = require('fs');
var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

var owner = web3.eth.coinbase;
var gasPrice = web3.eth.gasPrice;


configData = new Object();

var PriceTicker = web3.eth.contract(app.contracts.PriceTicker.info.abiDefinition);

var priceTickerInstance = PriceTicker.new({from: owner, gas: 300000, gasPrice: gasPrice, data: app.contracts.PriceTicker.code})


