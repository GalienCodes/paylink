import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying PayLink");
  const result = await deploy("PayLink", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: ["0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"],
        },
      },
    },
    waitConfirmations: 1,
    log: true,
  });
  console.log("========Deploying PayLink========");
  console.log("Contract address: ", result.address);
  
};

func.tags = ["PayLink"];

export default func;

// Deploying PayLink
// reusing "DefaultProxyAdmin" at 0xBD3d54122dBAF5355dfebb1F7243BE7af6AD55f2
// deploying "PayLink_Implementation" deployed at 0xe15Bac267992b7a7E07733356bD83A03e65cD437
// executing DefaultProxyAdmin.upgrade (tx: 0xe28fb0206eb26512053db8e5a5711930045f3ae38355d31b26d0889c6f909fee) ...: performed with 38688 gas
// ========Deploying PayLink========
//Contract address:  0x06B4637C35f7AA7220b6242BfBe89F8560dD30F2