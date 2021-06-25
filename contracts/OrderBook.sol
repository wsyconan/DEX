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

contract OrderBook {
    struct Item {
        uint32 next;
        Order order;
    }

    uint16 pairId; // <tokenId1>(8) <tokenId2>(8)
    uint32 first;
    uint32 count;
    Item[] items;
    uint32 constant NONE = uint32(0);

    // Mapping from orderId to index.
    mapping(uint32 => uint32) idToIndex;

    event DealCompleted(uint32 orderId, uint256 amount, address taker);

    constructor(uint16 _pairId) {
        pairId = _pairId;
        first = NONE;
        count = 0;
    }

    // Add an new order
    function append(
        uint256 _price,
        uint256 _amount,
        address _maker,
        uint32 _orderId
    ) public {
        // Order book is full.
        uint32 index = uint32(items.length);
        if (index > 0xFFFFFFFF) revert();
        items.push(Item(NONE, Order(_orderId, 0, _maker, _price, _amount)));
        idToIndex[_orderId] = index;
        // It is the first item.
        if (first == NONE) {
            require(first != NONE || count != 0);
            first = index;
            count = 1;
        } else {
            uint32 prevIndex = _findIndex(_price);
            items[index].next = items[prevIndex].next;
            items[prevIndex].next = index;
            count++;
        }
    }

    // Remove an order by index
    function remove(uint32 index) public {
        uint32 prevIndex = _findPrevIndex(index);
        // It is the first order
        if (prevIndex == NONE) {
            first = items[prevIndex].next;
        } else {
            items[prevIndex].next = items[index].next;
        }
        delete items[index];
        count--;
    }

    function findOrder(uint32 _orderId) public view returns (uint32) {
        return idToIndex[_orderId];
    }

    function changePrice(uint32 _orderId, uint256 newPrice) public {}

    function changeAmount(uint32 _orderId, uint256 newAmount) public {}

    // Look for possible deal.
    function findDeal(
        uint256 _price
    ) public returns (uint32) {
        uint32 index = first;
        while (index != NONE) {
            if (items[index].order.priceE8 < _price) {
                return index;
            }
            index = items[index].next;
        }
        return index;
    }

    function _veryfiyIndex(
        uint32 prevOrder,
        uint32 nextOrder,
        uint256 newprice
    ) internal view returns (bool) {
        return
            (prevOrder == 0 || items[prevOrder].order.priceE8 <= newprice) &&
            ((nextOrder == items.length - 1) ||
                items[nextOrder].order.priceE8 > newprice);
    }

    function _findIndex(uint256 newprice) internal view returns (uint32 index) {
        index = first;
        while (true) {
            if (_veryfiyIndex(index, items[index].next, newprice)) {
                return index;
            }
            index = items[index].next;
        }
    }

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
