import { expect } from "./chai-setup";
import { setupUsers, setupUser } from "./utils";
import { ethers, deployments, getNamedAccounts, getUnnamedAccounts } from 'hardhat';

async function setup() {
    await deployments.fixture(["Token"]);
    const contracts = {
        DEX: (await ethers.getContract('DEX')),
    };

    const { DEXAdmin } = await getNamedAccounts();

    const users = await setupUsers(await getUnnamedAccounts(), contracts);

    return {
        ...contracts,
        users,
        DEXAdmin: await setupUser(DEXAdmin, contracts),
    };
}

describe("DEX contract", function () {
    describe("Should initialize DEX.", async function () {
        it("Should set Tokens.", async function () {

        });

        it("Should create order books.", async function () {

        });
    });

    describe("Should initialize orders.", async function () {
        it("New order should be saved to order book.", async function () {

        });

        it("Should initizlize an opposite order.", async function () {

        });

        it("Another new order should be saved to order book.", async function () {

        });

        it("Another new order should be saved to order book.", async function () {

        });

        it("Another new order should be saved to order book.", async function () {

        });
    });

    describe("Should check order books.", async function () {
        it("Order book should save the remaining orders.", async function () {

        });
        
        it("Order book should be sorted in ascending by price.", async function () {

        });


    });

});