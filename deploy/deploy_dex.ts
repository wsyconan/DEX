import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;

  const {deployer, trader1, trader2} = await getNamedAccounts();

  await deploy('DEX', {
    from: deployer,
    args: [deployer],
    log: true,
  });
};
export default func;
func.tags = ['DEX'];