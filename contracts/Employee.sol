// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract Employee {

    struct EmployeeDetails{
        uint emp_id;
        string emp_name;
        uint deposit_balance; 
        address payable eth_address;
    }

    address payable  owner;
    
    mapping (uint => EmployeeDetails) public emp_det; // employee can identify by it's emp id...

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event AddEmployee(uint emp_id , string emp_name , uint deposit_balance , address eth_address);
    event updateItSelf(string emp_name);
    event checkDeposit(uint deposit_balance);
    event addFund(uint added_fund);
    event transferdFund(uint deposit_balance , uint transferdAmmount, uint charges);

    modifier checkOwner(){
        require(msg.sender == owner , "caller is not owner");
        _;
    }

     modifier checkEnployeeItSelf(uint _emp_id){
        require(msg.sender == emp_det[_emp_id].eth_address ,"only account can update itself");
        _;
    }

    modifier checkOwnerOrEmployeeItSelf(uint _emp_id){
        require(msg.sender == owner || msg.sender == emp_det[_emp_id].eth_address , "you must be a owner of the contract or account it self") ;
        _;
    }

    constructor() {
        console.log("Owner contract deployed by:", msg.sender);
        owner = payable(msg.sender);
        emit OwnerSet(address(0), owner);
    }

    //store emp id, name, ETH address and deposit for employee...
    //Should store emp id, name, ETH address and deposit for employee...
    //add funds into employee deposit by the owner and the ammount will be greater then 1000 Wie...
    //Owner can add more funds if he wants...
    function add_employee(uint _emp_id , string memory _emp_name , address payable _eth_address) checkOwner payable public{
        if(msg.value >= 1000){
            emp_det[_emp_id] = EmployeeDetails({ emp_id: _emp_id , emp_name: _emp_name , eth_address : _eth_address , deposit_balance : msg.value});
            emit AddEmployee(_emp_id, _emp_name , msg.value , _eth_address);
        }else{
            console.log("value must be greater then 1000 Wei");
        }
    }

    //only owner can see the total deposited value in the contract...
    function get_contract_balance() public view checkOwner returns(uint){
        return address(this).balance;
    }

    //only employee can update it's details... 
    function update_it_self(uint _emp_id ,string memory _emp_name) checkEnployeeItSelf(_emp_id) public {
        emp_det[_emp_id].emp_name = _emp_name;
        emit updateItSelf(_emp_name);
    }

    //employee can add fund into it's deposit balance...
    function add_fund(uint _emp_id) checkEnployeeItSelf(_emp_id) payable public {
        emp_det[_emp_id].deposit_balance = emp_det[_emp_id].deposit_balance + msg.value;
        emit addFund(msg.value);
    }

    //only employee can see it's own deposit balance any time...
    function check_deposit_balance(uint _emp_id) virtual  checkEnployeeItSelf(_emp_id) public returns (uint){
        emit checkDeposit(emp_det[_emp_id].deposit_balance);
        return emp_det[_emp_id].deposit_balance ;
    }

    //employe it self or owner can transfer fund to employee account and deduct the (10%) transaction fee which left smart contract account...
    function transfer_fund(uint _emp_id , uint _ammount) checkOwnerOrEmployeeItSelf(_emp_id) public{
        require(_ammount <= emp_det[_emp_id].deposit_balance , "amount which you entered to transfer in your account is more then the deposit balance");
            uint transferd_ammount = _ammount;
            emp_det[_emp_id].deposit_balance = emp_det[_emp_id].deposit_balance - _ammount;
            uint charges = (_ammount * 10) / 100;
            _ammount = _ammount - charges ;
            emp_det[_emp_id].eth_address.transfer(_ammount);
            emit transferdFund(emp_det[_emp_id].deposit_balance ,transferd_ammount , charges);
        }
    }

//Salary inherit The Property of it's Parent contract Employee
contract Salary is Employee {

   //employee and owner both can see the deposit balance of an employee...
    function check_deposit_balance(uint _emp_id) override  checkOwnerOrEmployeeItSelf(_emp_id) public returns (uint){
        emit checkDeposit(emp_det[_emp_id].deposit_balance);
        return emp_det[_emp_id].deposit_balance ;
    }
}