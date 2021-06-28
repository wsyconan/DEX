import {HardhatUserConfig} from 'hardhat/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';

import {accounts} from "./utils/network";

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.0',
  },
  namedAccounts: {
    deployer: 0,
    trader1: 1,
    trader2: 2,
  },
  paths: {
    sources: 'contracts',
    tests: 'test',
  },
  networks: {
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: accounts(),
    },
  },
};
export default config;