// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  /*
   * State variables
   */
   
  // <owner>
  address public owner;

  // <skuCount>
  uint public skuCount;

  // <items mapping>
  mapping(uint => Item) items;


  /*
   * Enums
   */

  // <enum State: ForSale, Sold, Shipped, Received>
  enum State {
    ForSale,
    Sold, 
    Shipped, 
    Received
  }

  /*
   * Structs
   */

  // <struct Item: name, sku, price, state, seller, and buyer>
  struct Item {
    string name;
    uint sku;
    uint price;
    address payable seller;
    address payable buyer;
    State state;
  }

  /* 
   * Events
   */

  // <LogForSale event: sku arg>
  event LogForSale(uint indexed sku);

  // <LogSold event: sku arg>
  event LogSold(uint indexed sku);

  // <LogShipped event: sku arg>
  event LogShipped(uint indexed sku);

  // <LogReceived event: sku arg>
  event LogReceived(uint indexed sku);

  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

  // <modifier: isOwner
  modifier isOwner() {
    require(owner == msg.sender, "You're not the owner");
    _;
  }

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address, "Caller does not match"); 
    _;
  }

  modifier paidEnough(uint _price) { 
    require(msg.value >= _price, "Item price is higher than amount sent"); 
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  // modifier forSale
  //// @title Modifier to check items by state
  //// @notice Only ForSale items are admitted
  //// @dev Needs to check both seller and buyer addresses once item state is not sufficient to guarantee.
  modifier forSale(uint sku) {
    require(
      items[sku].state == State.ForSale,
      "forSale:Item is not for Sale"
    );
    require(
      items[sku].seller != address(0),
      "forSale:Item does not have a seller address"
    );
    require(
      items[sku].buyer == address(0),
      "forSale:Item has a buyer address already"
    );
    _;
  }

  // modifier sold(uint _sku)
  //// @title Modifier to check items by state
  //// @notice Only Sold items are admitted
  modifier sold(uint sku) {
    require(
      items[sku].state == State.Sold,
      "sold:Item has not been sold yet"
    );
    _;
  }
  // modifier (uint _sku)
  //// @title Modifier to check items by state
  //// @notice Only Shipped items are admitted
  modifier shipped(uint sku) {
    require(
      items[sku].state == State.Shipped,
      "sold:Item has not been shipped yet"
    );
    _;
  }
  // modifier received(uint _sku)
  //// @title Modifier to check items by state
  //// @notice Only Received items are admitted
  modifier received(uint sku) {
    require(
      items[sku].state == State.Received,
      "sold:Item has not been received yet"
    );
    _;
  }

  constructor() {
    owner = msg.sender;
    // skuCount is already initialized with 0 as it is a uint variable and this is the default value.
  }

  function addItem(string memory _name, uint _price) public returns (bool) {
    items[skuCount] =  Item({
      name:   _name,
      sku:    skuCount,
      price:  _price,
      state:  State.ForSale,
      seller: payable(msg.sender),
      buyer:  payable(address(0))
    });
    skuCount++;
    emit LogForSale(skuCount);
    return true;
  }

  // Implement this buyItem function. 
  // 1. it should be payable in order to receive refunds
  // 2. this should transfer money to the seller, 
  // 3. set the buyer as the person who called this transaction, 
  // 4. set the state to Sold. 
  // 5. this function should use 3 modifiers to check 
  //    (a)- if the item is for sale, 
  //    (b)- if the buyer paid enough, 
  //    (c)- check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
  // 6. call the event associated with this function!
  function buyItem(uint sku) 
    public
    forSale(sku)
    paidEnough(items[sku].price)
    checkValue(sku)
    payable
  {
    items[sku].state = State.Sold;
    items[sku].seller.transfer(items[sku].price);
    items[sku].buyer = payable(msg.sender);
    emit LogSold(sku);
  }

  // 1. Add modifiers to check:
  //    (a)- the item is sold already 
  //    (b)- the person calling this function is the seller. 
  // 2. Change the state of the item to shipped. 
  // 3. call the event associated with this function!
  function shipItem(uint sku) 
    public
    sold(sku)
    verifyCaller(items[sku].seller)
  {
    items[sku].state = State.Shipped;
    emit LogShipped(sku);
  }

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint sku) 
  public
  shipped(sku)
  verifyCaller(items[sku].buyer)
  {
    items[sku].state = State.Received;
    emit LogReceived(sku);
  }

  // Uncomment the following code block. it is needed to run tests
  function fetchItem(uint _sku) public view 
    returns (string memory name, uint sku, uint price, uint state, address seller, address buyer)
  {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }
}
