// contracts/DEX.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OrderBook.sol";
import "../node_modules/hardhat/console.sol";

interface Token {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract DEX {
    struct TokenInfo {
        uint8 tokenCode;
        string symbol;
        address tokenAddr;
    }

    address public admin;
    //OrderBook[] private orderBooks;
    //TokenInfo[] private tokens;
    uint32 orderCounter;
    address constant WBNBAddr = 0xae13d989dac2f0debff460ac112a837c89baa7cd;
    address constant BUSDAddr = 0x8301f2213c0eed49a7e28ae4c3e91722919b8b47;
    mapping(string => TokenInfo) public tokens;
    mapping(uint16 => OrderBook) public orderBooks;

    event AddTOOrderBook(uint32);


    constructor(address _admin) {
        admin = _admin;
        orderCounter = 1;
        setToken(1, "WBNB", WBNBAddr);
        setToken(2, "BUSD", BUSDAddr);
        uint16 _pairId1 = uint16(1) | uint16(2 << 8);
        uint16 _pairId2 = uint16(2) | uint16(1 << 8);
        orderBooks[_pairId1] = new OrderBook(_pairId1);
        orderBooks[_pairId2] = new OrderBook(_pairId2);
    }

    function setToken(
        uint8 _tokenCode,
        string memory _symbol,
        address _address
    ) private {
        tokens[_symbol] = TokenInfo(_tokenCode, _symbol, _address);
    }

    // 
    function initOrder(
        string memory token1,
        string memory token2,
        uint256 _price,
        uint256 _amount
    ) public {
        require(Token(tokens[token1].tokenAddr).balanceOf(msg.sender) >= _amount);
        uint8 tokenCode1 = tokens[token1].tokenCode;
        uint8 tokenCode2 = tokens[token2].tokenCode;
        uint16 _pairId1 = (tokenCode1 << 8) | (tokenCode2);
        uint16 _pairId2 = (tokenCode2 << 8) | (tokenCode1);
        // Find an tradable order, return it's index.
        uint32 index = orderBooks[_pairId1].findDeal(_price);
        while(index != uint32(0) && _amount > 0) {
            Order memory temp = orderBooks[_pairId1].findOrder(index);
            // TO do
            if(temp.amountE8 < _amount){
                //To do
                _amount -= temp.amountE8;
                orderBooks[_pairId1].remove(index);
            } else if(temp.amountE8 > _amount) {
                // To do
                orderBooks[_pairId1].changeAmount(index, temp.amountE8 - _amount);
                _amount = 0;
            } else {
                // To do
                _amount = 0;
                orderBooks[_pairId1].remove(index);
            }
            index = orderBooks[_pairId1].findDeal(_price);
        }
        // Add an new order to OrderBook
        if(_amount != 0) {
            orderBooks[_pairId2].append(_price, _amount, msg.sender, orderCounter);
            emit AddTOOrderBook(orderCounter);
            orderCounter++;
        }
    }

    function makeDeal(address _from, address _to, string memory token, uint256 _amount) private {
        
    }
}
