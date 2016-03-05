module.exports = function(grunt) {

  var fs = require('fs');
  var Web3 = require('web3');

  grunt.registerTask('default', 'build');

  grunt.registerTask('test', 'Run tests.', function() {
    grunt.log.write('Running tests. ').ok();
  });

  grunt.registerTask('build', 'Create dapp.json', function() {
    var web3 = new Web3();
    web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));
    var ipcsocket = process.env['PWD'] + "/testnet/geth.ipc";
    var ipc3 = new Web3();
    ipc3.setProvider(new ipc3.providers.IpcProvider(ipcsocket));
    ipc3.personal
    var contractfile = "";
    var basedir = process.env['PWD'] + "/contracts/";
    var contracts = ["DAOInterface.sol", "DAO.sol", "TokenInterface.sol", "Token.sol"];
    contracts.forEach(function(contract) {
       contractfile = contractfile.concat(fs.readFileSync(basedir + contract, 'utf-8'));
    });
    var compiled = web3.eth.compile.solidity(contractfile);
  });

};
