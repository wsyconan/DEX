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
    function allowance(address owner, address spender) external view returns(uint256);
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
            if (temp.amountE8 < _amount) {
                // Transfer successful.
                if(transferToken(
                    msg.sender,
                    temp.maker,
                    token1,
                    token2,
                    temp.amountE8,
                    _price
                )){
                    _amount -= temp.amountE8;
                    orderBooks[_pairId1].remove(index);
                }
            } else if (temp.amountE8 > _amount) {
                // Transfer successful.
                if(transferToken(
                    msg.sender,
                    temp.maker,
                    token1,
                    token2,
                    _amount,
                    _price
                )) {
                    orderBooks[_pairId1].changeAmount(index, temp.amountE8 -= _amount);
                    _amount = 0;
                }

            } else {
                if(transferToken(
                    msg.sender,
                    temp.maker,
                    token1,
                    token2,
                    _amount,
                    _price
                )){
                    _amount = 0;
                    orderBooks[_pairId1].remove(index);
                }
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
    Use function transferFrom() to make the deal.
    trader1 send token1 to trader2, and trader2 send trader1 token1
    @param trader1 sender 
    @param trader2 recipient
    @param token1 name of token1
    @param token2 name of token2
    @param _amount amount of token1
    @param _price price of token2 exchange token1
    */
    function transferToken(
        address trader1,
        address trader2,
        string memory token1,
        string memory token2,
        uint256 _amount,
        uint256 _price
    ) private returns(bool) {
        require(Token(tokens[token1].tokenAddr).allowance(trader1, address(this)) >= _amount / 10 ** 8);
        require(Token(tokens[token2].tokenAddr).allowance(trader2, address(this)) >= (_price/ 10 ** 8) * (_amount / 10 ** 8));
        require(Token(tokens[token1].tokenAddr).balanceOf(trader1) >= _amount / 10 ** 8);
        require(Token(tokens[token2].tokenAddr).balanceOf(trader2) >= (_price/ 10 ** 8) * (_amount / 10 ** 8));
        return (Token(tokens[token1].tokenAddr).transferFrom(trader1, trader2, _amount / 10 ** 8) && Token(tokens[token2].tokenAddr).transferFrom(trader2, trader1, (_price/ 10 ** 8) * (_amount / 10 ** 8)));
    }
}
