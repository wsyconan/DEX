import { Contract } from 'ethers';
import { ethers } from 'hardhat';
import { ContractType } from 'hardhat/internal/hardhat-network/stack-traces/model';

export async function setupUsers<T extends {[ContractName: string]: Contract}>(
        addresses: string[],
        contracts: T
    ): Promise<({address: string} & T) []> {
    const users: ({address: string} & T)[] =[];
    for(const address of addresses) {
        users.push(await setupUser(address, contracts));
    }
    return users;
}

export async function setupUser<T extends {[contractName: string]: Contract}>(
        address: string,
        contracts: T
    ): Promise<{address: string} & T> {
        const user: any = {address};
        for(const key of Object.keys(contracts)) {
            user[key] = contracts[key].connect(await ethers.getSigner(address));
        }
        return user as {address: string} & T;
}