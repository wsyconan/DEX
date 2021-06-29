import {Contract, BigNumber, Signer} from 'ethers';
import {ethers} from 'hardhat';

export async function setupUsers<T extends { [contractName: string]: Contract }>(
    contracts: T
): Promise<({ address: string } & T)[]> {
    const users: ({ address: string } & T)[] = [];
    const addresses = ethers.getSigners();
    for (const address of addresses) {
        users.push(await setupUser(address, contracts));
    }
    return users;
}

export async function setupUser<T extends { [contractName: string]: Contract }>(
    address: Signer,
    contracts: T
): Promise<{ address: string } & T> {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const user: any = { address };
    for (const key of Object.keys(contracts)) {
        user[key] = contracts[key].connect(address);
    }
    return user as { await address.getAddress(): string } & T;
}
export const tokens = (value: number, decimals = 18) => BigNumber.from(value).mul(BigNumber.from(10).pow(decimals))

