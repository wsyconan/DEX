// contracts/OrderBook.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Order {
    uint32 orderId;
    uint8 status; // 0-active, 1-closed
    address maker; // Order maker address
    uint256 priceE8; // "E8" means the value stored is 10^8 times the actual value
    uint256 amountE8;
}

// Ordered order book, based on array, works like linked lists.
contract OrderBook {
    struct Item {
        uint32 next;  // index of next order
        Order order;
    }

    uint16 pairId; // <tokenId1>(8) <tokenId2>(8)
    uint32 first;
    uint32 count;  // order amount
    Item[] items;
    uint32 constant NONE = uint32(0);

    // Mapping from orderId to index.
    mapping(uint32 => uint32) idToIndex;

    constructor(uint16 _pairId) {
        pairId = _pairId;
        first = NONE;
        count = 0;
    }

    /** 
    Add an new order
    */
    function append(
        uint256 _price,
        uint256 _amount,
        address _maker,
        uint32 _orderId
    ) public {
        // Order book is full.
        uint32 index = uint32(items.length);
        if (index == 0xFFFFFFFF) revert();
        items.push(Item(NONE, Order(_orderId, 0, _maker, _price, _amount)));
        idToIndex[_orderId] = index;
        // It is the first item.
        if (count == 0) {
            first = index;
            count = 1;
        } else {
            uint32 prevIndex = _findIndex(_price);
            items[index].next = items[prevIndex].next;
            items[prevIndex].next = index;
            count++;
        }
    }

    /** 
    Remove an order by index
    */ 
    function remove(uint32 index) public {
        // It is the first order
        if (index == first) {
            first = items[index].next;
        } else {
            uint32 prevIndex = _findPrevIndex(index);
            items[prevIndex].next = items[index].next;
        }
        delete items[index];
        count--;
    }

    /** 
    Find order by index, return 
    */ 
    function findOrder(uint32 _index) public view returns (Order memory) {
        return items[idToIndex[_index]].order;
    }

    function changePrice(uint32 _orderId, uint256 newPrice) public {
        //Todo
    }

    function changeAmount(uint32 _orderId, uint256 newAmount) public {
        //Todo
    }

    /** 
    Look for possible deal. 
    @param _price excepted price.
    @return the index of tradable order.
    */
    function findDeal(
        uint256 _price
    ) public view returns (uint32) {
        uint32 index = first;
        while (index != NONE) {
            if (items[index].order.priceE8 < _price) {
                return index;
            }
            index = items[index].next;
        }
        return index;
    }

    /** 
    Assert current price is between previous order and next order. This function works with function _findIndex() to find the position where the new order is inserted.
    */
    function _verifyIndex(
        uint32 currOrder,
        uint32 nextOrder,
        uint256 price
    ) internal view returns (bool) {
        return
            (items[currOrder].order.priceE8 <= price) &&
            (nextOrder == NONE || items[nextOrder].order.priceE8 > price);
    }

    function _findIndex(uint256 newprice) internal view returns (uint32 index) {
        index = first;
        while (true) {
            if (_verifyIndex(index, items[index].next, newprice)) {
                return index;
            }
            index = items[index].next;
        }
    }

    /**
    Find index of previous order.
    */
    function _findPrevIndex(uint32 index) internal view returns (uint32) {
        if (index == first) return NONE;
        uint32 curr = first;
        while (items[curr].next != NONE) {
            if (items[curr].next == index) {
                return curr;
            }
            curr = items[curr].next;
        }
        return NONE;
    }
}
