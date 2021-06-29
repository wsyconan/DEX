import { expect } from "./chai-setup"
import { tokens } from "./utils/index"
import { ethers, deployments, getUnnamedAccounts } from 'hardhat'
import {setupUsers, setupUser} from './utils';
import { Contract, Signer } from "ethers"

describe("DEX contract", function () {
    
    async function setup() {
        const contracts = {
            DEX: await ethers.getContract('DEX'),
            BUSD: await (await ethers.getContractFactory("TestERC20")).deploy("BUSD", "BUSD"),
            WBNB: await (await ethers.getContractFactory("TestERC20")).deploy("WBNB", "WBNB")
        };
        const traders = await setupUsers(contracts);
        //const traderss = ethers.getSigners();
        for (const trader of traders) {
            await contracts.BUSD.transfer(trader.address, tokens(10_000))
            await contracts.WBNB.transfer(trader.address, tokens(10_000))
        }

        return {
            ...contracts,
            traders,
        }
    }

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
            await deployments.fixture(["DEX"]);
            const {DEX, traders} = await setup();
            //expect(DEX.deployed()).equal(true);
            await traders[0].WBNB.approve(DEX.address, 10);
            await traders[0].DEX.initOrder("WBNB", "BUSD", 10, 1);

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