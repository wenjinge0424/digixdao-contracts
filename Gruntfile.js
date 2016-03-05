module.exports = function(grunt) {

  grunt.registerTask('default', 'Log some stuff.', function() {
    grunt.log.write('Logging some stuff. ').ok();
  });

  grunt.registerTask('test', 'Run tests.', function() {
    grunt.log.write('Running tests. ').ok();
  });

  grunt.registerTask('build', 'Compile solidity contracts', function() {
    grunt.log.write('Building Package. ').ok();
    var solcbin = "/usr/local/bin/solc";
    var solcopts = "--bin";
    grunt.log.write('Using binary in ' + solcbin + ' ').ok();
  });

  grunt.registerTask('deploy', 'Deploy contracts to the testnet. [dev | morden | live]', function(network) {
    if (typeof network === "undefined") {
      network = "dev"
    }
    grunt.log.write('Deploying contracts on the ' + network + ' network. ' ).ok();
    grunt.task.run('build');
  });

};
