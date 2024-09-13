// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Ecommerce {
    struct Product {
        string title;
        string desc;
        address payable seller;
        uint productId;
        uint price;
        address buyer;
        bool isDelivered;
    }

    uint counter = 1; // Made counter public to track total products

    Product[] public products;

    event Registered(string title, uint productId, address seller);
    event Bought(uint productId, address buyer);
    event Delivered(uint productId);

    // Register a product for sale
    function registerProduct(string memory _title, string memory _desc, uint _price) public {
        require(_price > 0, "Price should be greater than zero");

        Product memory tempProduct;
        tempProduct.title = _title;
        tempProduct.desc = _desc;
        tempProduct.price = _price * 10**18; // Price converted to wei
        tempProduct.seller = payable(msg.sender);
        tempProduct.productId = counter;
        tempProduct.buyer = address(0); // Set buyer to address 0 initially
        tempProduct.isDelivered = false;

        products.push(tempProduct);
        emit Registered(_title, tempProduct.productId, msg.sender);

        counter++; // Increment product counter after registering
    }

    // Buy a product
    function buy(uint _productId) public payable {
        require(_productId > 0 && _productId <= products.length, "Invalid product ID");
        Product storage product = products[_productId - 1];
        
        require(msg.value == product.price, "Please pay the exact price");
        require(msg.sender != product.seller, "Seller cannot be the buyer");
        require(product.buyer == address(0), "Product already sold");

        product.buyer = msg.sender;

        emit Bought(_productId, msg.sender);
    }

    // Confirm delivery of a product
    function delivery(uint _productId) public {
        require(_productId > 0 && _productId <= products.length, "Invalid product ID");
        Product storage product = products[_productId - 1];

        require(product.buyer == msg.sender, "Only buyer can confirm delivery");
        require(product.isDelivered == false, "Product already delivered");

        product.isDelivered = true;
        product.seller.transfer(product.price); // Transfer the price to the seller

        emit Delivered(_productId);
    }
}