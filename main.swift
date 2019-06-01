//
//  main.swift
//  CoinSwiftPrototype
//
//  Created by McL on 1/1/19.
//  Copyright © 2019 McL. All rights reserved.
//

import Foundation

let initialDifficulty = 1

var ledger = Ledger(name: "Anonymous", difficulty: initialDifficulty)
ledger.printAccounts()

ledger.mining(transactions: [
    Transaction(
        inp: TransactionData(name: ledger.ledgerName, amount: 20),
        out: TransactionData(name: "Liz", amount: 20)),
    Transaction(
        inp: TransactionData(name: "Liz", amount: 5),
        out: TransactionData(name: "Dave", amount: 5)),
    Transaction(
        inp: TransactionData(name: "Liz", amount: 10),
        out: TransactionData(name: ledger.ledgerName, amount: 10))
    ])

ledger.printAccounts()

// create a new node and get blockchain up-to-date version of chain requesting it from another node
var ledger2 = Ledger(name: "Tom", difficulty: 0)
ledger2.setChain(ledger.chain)
ledger2.printAccounts()

// create a new node, but in this case ledger2 forged chain and add deleted transactions of the last block
ledger2.chain.head.payload.transactions = [Transaction]()

var ledger3 = Ledger(name: "Leonardo", difficulty: 0)
ledger3.setChain(ledger2.chain)
ledger3.printAccounts()

//let block1 = Block(
//    parent:
//        Block(
//            parent: nil,
//            payload: CoinPayload(
//                coinbase: TransactionData(name: "Dave", amount: 100)), // reward
//            transactions: [
//                Transaction(
//                    inp: TransactionData(name: "Anonymous", amount: 50),
//                    out: TransactionData(name: "Mary", amount: 50))
//            ]
//        ),
//    payload: CoinPayload(
//        coinbase: TransactionData(name: "Dave", amount: 100))) // reward
//
//let transactionBlock1 = Transaction(
//    inp: TransactionData(name: "Anonymous", amount: 50),
//    out: TransactionData(name: "Mary", amount: 50))
//block1.payload.addTransaction(transactionBlock1)


//let block1 = Block(
//    parent: blockchain.head,
//    payload: CoinPayload(
//        coinbase: TransactionData(name: "Dave", amount: 100)))
//
//let transactionBlock1 = Transaction(
//    inp: TransactionData(name: "Anonymous", amount: 50),
//    out: TransactionData(name: "Mary", amount: 50))
//block1.payload.addTransaction(transactionBlock1)
//block1.mine(for: blockchain)
//blockchain.append(block1)
//
//
//
//let transactionBlock2 = [
//    Transaction(
//        inp: TransactionData(name: "Mary", amount: 20),
//        out: TransactionData(name: "Liz", amount: 20)),
//    Transaction(
//        inp: TransactionData(name: "Liz", amount: 5),
//        out: TransactionData(name: "Dave", amount: 5)),
//    Transaction(
//        inp: TransactionData(name: "Anonymous", amount: 20),
//        out: TransactionData(name: "Liz", amount: 20))]
//
//let block2 = Block(
//    parent: blockchain.head,
//    payload: CoinPayload(
//        coinbase: TransactionData(name: "Anonymous", amount: 100)))
//block2.payload.addTransactions(transactionBlock2)
//block2.mine(for: blockchain)
//blockchain.append(block2)


//let block3 = Block(
//    parent: blockchain.head,
//    payload: CoinPayload(
//        coinbase: TransactionData(name: "Anonymous", amount: 100)))
//block3.mine(for: blockchain)
//blockchain.append(block3)
// nonce = 139

//print("Received block is valid:")
//print(block2.receivedBlockIsValid(foundNonce: block2.nonce, difficulty: 2))
//print("-------")


//var ledger = Ledger(blockchain)
//ledger.setup()
//ledger.printAccounts()


//let block3 = Block(
//    parent: blockchain.head,
//    payload: CoinPayload(
//        coinbase: TransactionData(name: "Anonymous", amount: 100)),
//    nonce: 138)
//block3.updateBlockCreated()
//
//ledger.updateChainWithReceived(newBlock: block3)
////ledger.printAccounts()
//
//
//let block4 = Block(
//    parent: blockchain.head,
//    payload: CoinPayload(
//        coinbase: TransactionData(name: "Anonymous", amount: 100)),
//    nonce: 139)
//block4.updateBlockCreated()
//
//ledger.updateChainWithReceived(newBlock: block4)
//ledger.printAccounts()


//modify blockchain for another node
//let extraTransaction = Transaction(
//    inp: TransactionData(name: "Mary", amount: 20),
//    out: TransactionData(name: "Liz", amount: 20))
//
//blockchain.head.parent?.parent?.payload.addTransaction(extraTransaction)
//
//var ledger2 = Ledger(blockchain)
//ledger2.setup()
//ledger.printAccounts()
