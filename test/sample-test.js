const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Mint", function () {
  it("Verificar o suplly do contrato e owner", async function () {
    const CryptoToken = await ethers.getContractFactory("CryptoToken");
    const crypto = await CryptoToken.deploy(100);
    await crypto.deployed();
    await crypto.mint(100);

    const[owner] = await ethers.getSigners();
    expect(await crypto.totalSupply()).to.equal(200);
    expect(await crypto.balanceOf(owner.address)).to.equal(200);
  });

  it("Verificar o suplly do owner", async function () {
    const CryptoToken = await ethers.getContractFactory("CryptoToken");
    const crypto = await CryptoToken.deploy(100);
    await crypto.deployed();
    await crypto.mint(100);

    const[owner] = await ethers.getSigners();
    expect(await crypto.balanceOf(owner.address)).to.equal(200);
  });

  it("Sender is not owner!", async function() {
    const CryptoToken = await ethers.getContractFactory("CryptoToken");
    const crypto = await CryptoToken.deploy(100);
    await crypto.deployed();

    const[owner, wallet] = await ethers.getSigners();
    let err = "";

    try {
      await crypto.connect(wallet).mint(10);
    } catch (e) {
      err = e.message;
    }
    expect(err).to.equal("VM Exception while processing transaction: reverted with reason string 'Sender is not owner!'");   
  }); 

});

describe("Burn", function () {
  it("Verificar o suplly do contrato", async function () {
    const CryptoToken = await ethers.getContractFactory("CryptoToken");
    const crypto = await CryptoToken.deploy(100);
    await crypto.deployed();
    await crypto.burn(100);

    const[owner] = await ethers.getSigners();
    expect(await crypto.totalSupply()).to.equal(0);
    expect(await crypto.balanceOf(owner.address)).to.equal(0);
  });

  it("Sender is not owner!", async function() {
    const CryptoToken = await ethers.getContractFactory("CryptoToken");
    const crypto = await CryptoToken.deploy(100);
    await crypto.deployed();

    const[owner, wallet] = await ethers.getSigners();
    let err = "";

    try {
      await crypto.connect(wallet).burn(10);
    } catch (e) {
      err = e.message;
    }
    expect(err).to.equal("VM Exception while processing transaction: reverted with reason string 'Sender is not owner!'");   
  });

  it('Tranferir token do owner para outra conta e verificar o supply', async()=>{
    const CryptoToken = await ethers.getContractFactory("CryptoToken");
    const crypto = await CryptoToken.deploy(100);
    await crypto.deployed();

    const [owner, wallet] = await ethers.getSigners(); 

    const transfer = await crypto.connect(owner)
    .transfer(wallet.address, 50);
    await transfer.wait();

    expect(await crypto.balanceOf(wallet.address)).to.equal(50);
    expect(await crypto.balanceOf(owner.address)).to.equal(50);
    expect(await crypto.totalSupply()).to
    .equal(parseInt(await crypto.balanceOf(wallet.address)) + parseInt(await crypto.balanceOf(owner.address)));
  });
  
});