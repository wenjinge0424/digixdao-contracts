module.exports = {
  contractBase: function() {
    return process.env['PWD'] + "/contracts/";
  },
  buildBase: function() {
    return process.env['PWD'] + "/build/";
  },
};
