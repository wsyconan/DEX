// contracts/DEX.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./OrderBook.sol";
//import "../node_modules/hardhat/console.sol";


interface Token {
    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
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
    address constant WBNBAddr = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant BUSDAddr = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    mapping(string => TokenInfo) public tokens;
    mapping(uint16 => OrderBook) public orderBooks;

    event AddToOrderBook(uint32 orderId);

    constructor(address _admin) {
        admin = _admin;
        orderCounter = 1;
        setToken(1, "WBNB", WBNBAddr);
        setToken(2, "BUSD", BUSDAddr);
        console.log("Contract address Token WBNB: %s.", WBNBAddr);
        console.log("Contract address Token BUSD: %s.", BUSDAddr);
        //Todo: Need a function to automatically generate order books.
        uint16 _pairId1 = uint16(1) | uint16(2 << 8);
        uint16 _pairId2 = uint16(2) | uint16(1 << 8);
        orderBooks[_pairId1] = new OrderBook(_pairId1);
        orderBooks[_pairId2] = new OrderBook(_pairId2);
        console.log("Add an order book, pairId is: %s.", _pairId1);
        console.log("Add an order book, pairId is: %s.", _pairId2);
    }

    /**
    Add an ERC20 token in DEX
    @param _tokenCode code of the Token
    @param _symbol symbol of the Token
    @param _address Contract address of the Token
    */
    function setToken(
        uint8 _tokenCode,
        string memory _symbol,
        address _address
    ) public {
        require(msg.sender == admin);
        tokens[_symbol] = TokenInfo(_tokenCode, _symbol, _address);
    }

    /**
    This function is used to initiate an exchange.
    @param token1 current token
    @param token2 target token
    @param _price excepted price. Formula - target token/current token
    @param _amount exchange amount(current token)
    */
    function initOrder(
        string memory token1,
        string memory token2,
        uint256 _price,
        uint256 _amount
    ) public {
        require(Token(tokens[token1].tokenAddr).balanceOf(msg.sender) >= _amount);
        console.log("Address of order maker is: %s", msg.sender);
        uint8 tokenCode1 = tokens[token1].tokenCode;
        uint8 tokenCode2 = tokens[token2].tokenCode;
        uint16 _pairId1 = (tokenCode1 << 8) | (tokenCode2);
        uint16 _pairId2 = (tokenCode2 << 8) | (tokenCode1);
        // Find an tradable order, return it's index.
        uint32 index = orderBooks[_pairId1].findDeal(_price);
        while (index != uint32(0) && _amount > 0) {
            console.log("There is a tradable order.");
            Order memory temp = orderBooks[_pairId1].findOrder(index);
            // To do
            if (temp.amountE8 < _amount) {
                //To do
                _amount -= temp.amountE8;
                orderBooks[_pairId1].remove(index);
            } else if (temp.amountE8 > _amount) {
                // To do
                orderBooks[_pairId1].changeAmount(
                    index,
                    temp.amountE8 - _amount
                );
                _amount = 0;
            } else {
                // To do
                _amount = 0;
                orderBooks[_pairId1].remove(index);
            }
            index = orderBooks[_pairId1].findDeal(_price);
        }
        // Add an new order to OrderBook
        if (_amount != 0) {
            orderBooks[_pairId2].append(
                _price,
                _amount,
                msg.sender,
                orderCounter
            );
            emit AddToOrderBook(orderCounter);
            orderCounter++;
        }
    }

    /**
    Use function transferFrom() to send ERC20 token
    @param _from sender 
    @param _to recipient
    @param token name of token to be sent
    @param _amount amount sent 
    */
    function transferToken(
        address _from,
        address _to,
        string memory token,
        uint256 _amount
    ) private {
        require(Token(tokens[token].tokenAddr).balanceOf(_from) >= _amount);
        Token(tokens[token].tokenAddr).transferFrom(_from, _to, _amount);
    }
}
