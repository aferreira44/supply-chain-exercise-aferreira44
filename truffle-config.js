module.exports = {
  networks: {
    local: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    }
  },
  // To run contract with the latest compiler, uncomment lines 10-14 below:
  compilers: { 
    solc: {
      version: ">=0.5.16 <0.9.0",    // Fetch latest 0.8.x Solidity compiler 
    }
  }
};
