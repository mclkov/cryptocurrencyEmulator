//
//  CoinPayload.swift
//  CoinSwiftPrototype
//
//  Created by McL on 1/1/19.
//  Copyright © 2019 McL. All rights reserved.
//

import Foundation

protocol BlockPayload {
    var coinbase: TransactionData { get }
    var transactions: [Transaction] { get }
    var payloadHash: String { get }
    
    mutating func addTransaction(_ transaction: Transaction)
    mutating func addTransactions(_ transactionsList: [Transaction])
}

struct Payload: BlockPayload {    
    let coinbase: TransactionData
    var transactions: [Transaction]
    
    var payloadHash: String {
        let payloadString = String(describing: transactions) + String(describing: coinbase)
        return payloadString.md5sum()
    }
    
    init(coinbase: TransactionData, transactions: [Transaction] = []) {
        self.coinbase = coinbase
        self.transactions = transactions
    }
    
    mutating func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    mutating func addTransactions(_ transactionsList: [Transaction]) {
        for t in transactionsList {
            addTransaction(t)
        }
    }
}
