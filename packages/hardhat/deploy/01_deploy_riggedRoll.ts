import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat/";
import { DiceGame, RiggedRoll } from "../typechain-types";

const deployRiggedRoll: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const diceGame: DiceGame = await ethers.getContract("DiceGame");
  const diceGameAddress = await diceGame.getAddress();

  await deploy("RiggedRoll", {
    from: deployer,
    log: true,
    args: [diceGameAddress],
    autoMine: false,
  });

  const riggedRoll: RiggedRoll = await ethers.getContract("RiggedRoll", deployer);
  //  await riggedRoll.riggedRoll({ value: ethers.parseEther("0.2") });
  // Please replace the text "Your Address" with your own address.
  try {
    await riggedRoll.transferOwnership("0x4B72454e042f951958829D0B62BBf52c63ACC382");
  } catch (err) {
    console.log(err);
  }
};

export default deployRiggedRoll;

deployRiggedRoll.tags = ["RiggedRoll"];
