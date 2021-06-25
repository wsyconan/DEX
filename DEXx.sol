// contracts/DEX.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OrderBook.sol";
import "hardhat/console.sol";

contract DEX {
    // Informations of Token
    struct TokenInfo {
        string symbol;
        address tokenAddress;
    }

    address public admin; // admin address
    OrderBook[] private orderBooks;
    TokenInfo[] private tokens;
    uint32 orderCount;
    mapping(string => uint8) public tokenCodes;
    mapping(string => address) public tokenAddresses;
    mapping(uint16 => OrderBook) public orderBookMapping;

    constructor(address _admin) {
        admin = _admin;
        orderCounter = 1;
        setToken(0, "WBNB", address(0xB8c77482e45F1F44dE1745F52C74426C631bDD52));
        setToken(1, "BUSD", address(0x4Fabb145d64652a948d72533023f6E7A623C7C5));
        // Create orderbooks
        for (uint256 i = 0; i < tokens.length - 1; i++) {
            for (uint256 j = 0; j < tokens.length - 1; j++) {
                uint8 code1 = tokenCodes[tokens[i].symbol];
                uint8 code2 = tokenCodes[tokens[j].symbol];
                uint16 _pairId = uint16(code1) | (uint16(code2) << 8);
                OrderBook _orderBook = new OrderBook(_pairId);
                orderBooks.push(_orderBook);
                orderBookMapping[_pairId] = _orderBook;
            }
        }
    }

    function setToken(uint8 tokenCode, string memory _symbol, string memory _address) public {
        require(msg.sender == admin);
        tokenCodes[_symbol] = tokenCode;
        tokenAddresses[_symbol] = _address;
        tokens.push(TokenInfo(_symbol, _address));
    }

    // Initiate an order
    function initOrder(
        string memory token1,
        string memory token2,
        uint256 _price,
        uint256 _amount
    ) public {
        require(token1 != token2);
        require(tokenAddresses[token1].balanceof(msg.sender) >= _amount);
        uint8 tokenCode1 = tokenCodes[token1];
        uint8 tokenCode2 = tokenCodes[token2];
        uint16 _pairId1 = (tokenCode1 << 8) | tokenCode2;
        uint16 _pairId2 = (tokenCode2 << 8) | tokenCode1;
        
        uint32 index = orderBookMapping[_pairId1].findDeal(_price, _amount);
        // There is an opposite order
        while(index != uint32(0) || _amount > 0) {
            Order memory temp = orderBookMapping[_pairId1].findOrder(index);
            // Amount of order in order book more than the new order.
            if(temp.amountE8 <  _amount) {
                _amount -= temp.amountE8;
                orderBookMapping[_pairId1].remove(index);
            } else if (temp.amountE8 <  _amount) {
                // Order in order book less than new order.
                orderBookMapping[_pairId1].changeAmount(index, temp.amountE8 - _amount);
                _amount = 0;
            } else {
                // Order in order book equals to new order.
                orderBookMapping[_pairId1].remove(index);
                _amount = 0;
            }
            index = orderBookMapping[_pairId1].findDeal(_price, _amount);
        }
        _amount = orderBookMapping[_pairId1].findDeal(_price, _amount, msg.sender);
        // Add order to order book
        if(_amount != 0) {
            orderBookMapping[_pairId2].append(_price, _amount, msg.sender, orderCounter);
            orderCounter++;
        }       
    }

    // 
    function makeADeal(uint32 _orderId, uint16 _pairId, uint256 _amount,address maker, address taker) private {
        tokencodes[uint7(_pairId>>8)]
    }

}
