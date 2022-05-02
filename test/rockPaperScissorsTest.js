const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require('bignumber.js');

describe("Rock, Paper, Scissors", () => {

  let RPS, rps, owner, alice, bob;

  beforeEach(async () => {
    const RPS = await ethers.getContractFactory("RPS_ERC20");
    rps = await RPS.deploy();
    [owner, alice, bob, _] = await ethers.getSigners();
    rps.connect(alice).mint({value: 10});
    rps.connect(bob).mint({value: 10});
  });

  it("Should be able to enroll multiple times", async () => {
    await rps.connect(alice).enroll(0,0);
    await rps.connect(alice).enroll(1,1);
    await rps.connect(alice).enroll(2,2);
    expect(await rps.getLength()).to.equal(3);
    expect(await rps.balance(alice.address)).to.equal(7);
  });

  it("Should be able to play", async function () {
    await rps.connect(alice).enroll(0,1);
    await rps.connect(bob).play(0, 1);
    expect(await rps.viewWinner(0)).to.equal(bob.address);
    expect(await rps.balance(alice.address)).to.equal(9);
    expect(await rps.balance(bob.address)).to.equal(11);
  });

  it("Should be able to cancel wage", async function () {
    await rps.connect(alice).enroll(0, 8);
    expect(await rps.balance(alice.address)).to.equal(2);
    await rps.connect(alice).cancelWage(0);
    expect(await rps.balance(alice.address)).to.equal(10);
    let ids, wages;
    [ids, wages] = await rps.viewOpenWages();
    expect(ids.length).to.equal(0);
  });

  it("Should return wage to both players in case of tie", async function () {
    await rps.connect(alice).enroll(0, 10);
    expect(await rps.balance(alice.address)).to.equal(0);
    await rps.connect(bob).play(0, 0);
    expect(await rps.balance(alice.address)).to.equal(10);
    expect(await rps.balance(bob.address)).to.equal(10);
    let ids, wages;
    [ids, wages] = await rps.viewOpenWages();
    expect(ids.length).to.equal(0);
  });

  xit("Should fail if player has not enough wei to wage", async function () {
    await expect(await rps.connect(alice).enroll(0, 11)).to.be.revertedWith("Not enough wei.");
  });

});
