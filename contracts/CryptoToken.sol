// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {

    //Implementado (mais ou menos)
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);

    //Não implementados (ainda)
    //function allowence(address owner, address spender) external view returns(uint256);
    //function approve(address spender, uint256 amount) external returns(bool);
    //function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    //Implementado
    event Transfer(address from, address to, uint256 value);
    event Burn(address owner, uint256 value, uint256 supply);
    event Mint(address owner, uint256 BalanceOwner, uint256 amount, uint256 supply);
    //Não está implementado (ainda)
    //event Approval(address owner, address spender, uint256 value);

}

contract CryptoToken is IERC20 {

    // Enum
    enum Status { ACTIVE, PAUSED, CANCELLED } // mesmo que uint8

    //Properties
    address private owner;
    string public constant name = "CryptoToken";
    string public constant symbol = "CRY";
    uint8 public constant decimals = 3;  //Default dos exemplos é sempre 18
    uint256 private totalsupply;
    Status contractState; 

    // Modifiers
    modifier isOwner() {
        require(msg.sender == owner , "Sender is not owner!");
        _;
    }

     // Events
    //event Mint(address owner, uint256 BalanceOwner, uint256 amount, uint256 supply);
   //event Burn(address owner, uint256 amount, uint256 supply);
    //event Transfer(address sender, address receiver, uint256 amount);

    mapping(address => uint256) private addressToBalance;
 
    //Constructor
    constructor(uint256 total) {
        owner = msg.sender;
        totalsupply = total;
        addressToBalance[msg.sender] = totalsupply;
        contractState = Status.ACTIVE;
    }

    //Public Functions
    function totalSupply() public override view returns(uint256) {
        return totalsupply;
    }

    function balanceOf(address tokenOwner) public override view returns(uint256) {
        return addressToBalance[tokenOwner];
    }

    function transfer(address receiver, uint256 quantity) public override returns(bool) {
        require(quantity <= addressToBalance[msg.sender], "Insufficient Balance to Transfer");
        addressToBalance[msg.sender] -= quantity;
        addressToBalance[receiver] += quantity;

        emit Transfer(msg.sender, receiver, quantity);
        return true;
    }

     function state() public view returns(Status) {
        return contractState;
    }

    function setState(uint8 status) public isOwner {
        if(status == 1){
            contractState = Status.ACTIVE;
        }
        if(status == 2){
            contractState = Status.PAUSED;
        }
        if(status == 3){
            contractState = Status.CANCELLED;
            kill(payable(owner));
        }       
    }

    function mint(uint256 amount) public isOwner {
        require(contractState == Status.ACTIVE, "Contrato esta pausado!");
        
        totalsupply += amount;
        addressToBalance[owner] += amount;
        
        emit Mint(owner,addressToBalance[owner], amount, totalSupply());       
    }


    function burn(uint256 amount) public isOwner {
        require(contractState == Status.ACTIVE, "Contrato esta pausado!");
        require(totalSupply() >= amount, "O valor excede o seu saldo");
        totalsupply -= amount;
        addressToBalance[owner] -= amount;

        emit Burn(owner, amount, totalSupply());
    }

    // Kill
    function kill(address payable _to) public isOwner {
        setState(3);
        selfdestruct(_to);
    } 
}