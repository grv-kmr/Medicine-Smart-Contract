// SPDX-License-Identifier: MIT
pragma solidity 0.8;

contract Medicine{

    struct Medicines{
        uint quantity;
        uint unitprice;
    }
    event medicinestock(string medicinename, uint medicineunit, uint unitprice);
    event medicinepurchaced(string medname, uint medunit, uint medprice);
    mapping(string => Medicines) public medicineMapping;
    string[] public medicineList; 

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);

    }

    function addnewmedicine(string memory _newmedicine, uint _quantity, uint _unitprice) onlyOwner public{
       
        require(medicineMapping[_newmedicine].quantity == 0, "Medicine already exists");
        medicineMapping[_newmedicine] = Medicines(_quantity, _unitprice);
        medicineList.push(_newmedicine);

        emit medicinestock (_newmedicine ,_quantity,_unitprice);
        
    }

    function stockmedicine() public view returns(uint){
            return medicineList.length;
    }
    modifier cost(uint _quantity, uint _price) {
        require(msg.value == (_price * _quantity),"Incorrect ether value given");
        _;
    }
    
    modifier existingornot(string memory _medname){
        require(medicineMapping[_medname].quantity > 0 ,"Medicine unavailable");
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    function buymedicine(string memory _medname, uint _quantity) cost(_quantity,medicineMapping[_medname].unitprice) existingornot(_medname)
     payable public {
        Medicines storage medicinestorage = medicineMapping[_medname];
        require(medicinestorage.quantity > _quantity,"Not enough quantity");
        (bool sent, bytes memory data) = owner.call{value: msg.value}("");
        require(sent, "Payment failed");
        medicinestorage.quantity -= _quantity;
        emit medicinepurchaced(_medname, _quantity, _quantity * medicineMapping[_medname].unitprice);
        
    }

    function updatemedicine(string memory _medname, uint _newquantity, uint _newunitprice) onlyOwner public{
        medicineMapping[_medname] = Medicines(_newquantity, _newunitprice);
    }

    function getmedicinetable() public view returns (string[] memory, uint[] memory, uint[] memory){
        uint length = medicineList.length;
        uint[] memory quantity = new uint [](length);
        uint[] memory price= new uint[] (length);
        for(uint i = 0 ;i < medicineList.length;++i ){
            Medicines storage medicinestorage = medicineMapping[medicineList[i]]; 
                quantity[i] = medicinestorage.quantity;
                price[i]= medicinestorage.unitprice;
        }
        return (medicineList, quantity, price);
        
    }

    function deletemedicine(string memory _medname) onlyOwner public {
        delete medicineMapping[_medname];

        for(uint i = 0; i < medicineList.length ;++i){
            if (keccak256(abi.encodePacked(medicineList[i])) == keccak256(abi.encodePacked(_medname))){
                medicineList[i] = medicineList[medicineList.length - 1];
                medicineList.pop();
            }
        }
    }
    
}
