import { expect } from "./chai-setup";
import { setupUsers, setupUser } from "./utils";
import { ethers, deployments, getNamedAccounts, getUnnamedAccounts } from 'hardhat';

async function setup() {
    await deployments.fixture(["DEX"]);
    const contracts = {
        DEX: (await ethers.getContract('DEX')),
    };

    //const users = await getUnamedAccounts();

    const {trader1} = await getNamedAccounts();
    const {trader2} = await getNamedAccounts();
    const {deployer} = await getNamedAccounts();

    return {
        ...contracts,
        trader1: await setupUser(trader1, contracts),
        trader2: await setupUser(trader2, contracts),
    };
}

describe("DEX contract", function () {
    describe("Should initialize DEX.", function () {
        it("Should set Tokens.", async function () {
            await deployments.fixture(["DEX"]);
            const DEX = await ethers.getContract("DEX");
            //expect(DEX.tokens["WBNB"]).not.null;
            //expect(DEX.tokens["BUSD"]).not.equal(0);
        });

        it("Should create order books.", async function () {
            await deployments.fixture(["DEX"]);
            const DEX = await ethers.getContract("DEX");
            //expect(DEX.orderBooks[65536].first).equal(0);
            //expect(DEX.orderBooks[1].first).equal(0);
        });
    });

    describe("Should initialize orders.", function () {
        it("New order should be saved to order book.", async function () {
            //await deployments.fixture(["DEX"]);
            const {DEX, trader1} = await setup();
            //expect(DEX.deployed()).equal(true);
            await trader1.DEX.initOrder("WBNB", "BUSD", 10, 1);
            expect(DEX.orderBooks[513].count).equal(1);
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

    describe("Should check order books.", function () {
        it("Order book should save the remaining orders.", async function () {

        });

        it("Order book should be sorted in ascending by price.", async function () {

        });


    });

});