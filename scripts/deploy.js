const hre = require("hardhat");

async function main() {
  console.log("Deploying InsuranceProtocol to Core Testnet 2...");

  // Get the contract factory
  const InsuranceProtocol = await hre.ethers.getContractFactory("InsuranceProtocol");
  
  // Deploy the contract
  const insuranceProtocol = await InsuranceProtocol.deploy();

  // Wait for deployment to finish
  await insuranceProtocol.waitForDeployment();
  
  const address = await insuranceProtocol.getAddress();
  console.log("InsuranceProtocol deployed to:", address);
}

// Execute the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
