var TomoBird = artifacts.require("./TomoBird");
module.exports = function(deployer) {
  deployer.deploy(TomoBird,"0xb9e18ED7f0e826C2a679c4573Ee2B9a5Cc0b825F" , {gas: 500000});
};