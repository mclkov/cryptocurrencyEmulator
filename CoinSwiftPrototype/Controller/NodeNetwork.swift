//
//  TestBlockChain.swift
//  CoinPrototypeTest
//
//  Created by McL on 1/10/19.
//  Copyright © 2019 McL. All rights reserved.
//

import Foundation

class NodeNetwork {
    let initialDifficulty = 2
    var ledgers = [String: Ledger]()
}

extension NodeNetwork {
    // filling function
    func createLedgerAlice() {
        self.generateLedger(name: "Alice", lookForLongest: true)
    }
    
    // filling function
    func generateBlockForLedger(name: String, extraTransaction: Transaction? = nil) {
        var transactions = [
            Transaction(
                inp: TransactionData(name: name, amount: 20),
                out: TransactionData(name: "Liz", amount: 20)),
            Transaction(
                inp: TransactionData(name: "Liz", amount: 5),
                out: TransactionData(name: "Dave", amount: 5)),
            Transaction(
                inp: TransactionData(name: "Liz", amount: 10),
                out: TransactionData(name: name, amount: 10))
        ]
        
        if let addTransaction = extraTransaction {
            transactions.append(addTransaction)
        }
        
        let block = self.ledgers[name]!.mining(transactions: transactions)
        if block.stopSignal == false {
            ledgers[name]!.addLog("\(Measurement.getCurrentTime()) \(name) sends to all nodes new mined block: \(block)")
            self.sendNewBlockToAllNodes(block)
        }
    }
    
    // filling function
    func generateInvalidBlockForLedger(name: String, extraTransaction: Transaction? = nil) -> Block {
        var transactions = [
            Transaction(
                inp: TransactionData(name: name, amount: 20),
                out: TransactionData(name: "Liz", amount: 20)),
            Transaction(
                inp: TransactionData(name: "Liz", amount: 5),
                out: TransactionData(name: "Dave", amount: 5)),
            Transaction(
                inp: TransactionData(name: "Liz", amount: 10),
                out: TransactionData(name: name, amount: 10))
        ]
        
        if let addTransaction = extraTransaction {
            transactions.append(addTransaction)
        }
        
        let block = self.ledgers[name]!.miningInvalidBlock(transactions: transactions)
        if block.stopSignal == false {
            ledgers[name]!.addLog("\(Measurement.getCurrentTime()) \(name) sends to all nodes new mined block: \(block)")
            self.sendNewBlockToAllNodes(block)
        }
        
        return block
    }
    
    func sendNewBlockToAllNodes(_ block: Block) {
        for (name, ledger) in ledgers {
            if name != block.payload.coinbase.name {
                
                // technically, the next functionality should be implemented on the level of Ledger
                // the problem is it's impossible since class Ledger doesn't know anything about other Ledgers
                // and the only link is this class - NodeNetwork
                
                // if new block is based on Ledger's current block
                let blockBasedOnCurrentLedgerBlock = block.hasParent(block: ledger.chain.head)
                if blockBasedOnCurrentLedgerBlock {
                    ledgers[name]!.processReceivedBlockAndStopMining(block)
                } else {
                    if let longestChain = findLongestChain(currentLedger: ledger) {
                        let chainIsTheSame = longestChain.head.recalculatedHash() == ledger.chain.head.recalculatedHash()
                        if !chainIsTheSame {
                            ledgers[name]!.interruptMining()
                            ledgers[name]!.addLog("\(Measurement.getCurrentTime()) \(name) switched to the longer chain")
                            ledgers[name]!.addLog("head block is created by \(longestChain.head.payload.coinbase.name)")
                            ledgers[name]!.setChain(longestChain)
                        }
                    } else {
                        fatalError("Cannot find neither Longest chain, nor parent block")
                    }
                }
            }
        }
    }
    
    func generateLedger(name: String, lookForLongest: Bool) {
        let ledgerName = name
        let ledger = Ledger(name: ledgerName, difficulty: self.initialDifficulty)
        
        if lookForLongest == true {
            if let longestChain = findLongestChain(currentLedger: ledger) {
                ledger.addLog("\(ledgerName) switched to the longer chain")
                ledger.addLog("head block is created by \(longestChain.head.payload.coinbase.name)")
                ledger.setChain(longestChain)
            }
        }
        
        self.addLedger(name: ledgerName, ledger)
    }
    
    func findLongestChain(currentLedger: Ledger) -> Blockchain? {
        var chainList = [Int: Ledger]()
        
        for (name, ledger) in ledgers {
            let blocksCount = currentLedger.calculateValidBlocksOf(externalChain: ledger.chain)
            chainList[blocksCount] = ledger
        }
        return getLongestChain(ledgersList: chainList)
    }
    
    func getLongestChain(ledgersList: [Int: Ledger]) -> Blockchain? {
        if ledgersList.count == 0 {
            return nil
        }
        let sorted = ledgersList.sorted(by: { $0.key > $1.key })
        return sorted[0].value.chain
    }
    
    private func addLedger(name: String, _ ledger: Ledger) {
        if ledgerExists(name: name) {
            fatalError("Ledger \(name) already exists")
        } else {
            self.ledgers[name] = ledger
        }
    }
    
    func ledgerExists(name: String) -> Bool {
        if self.ledgers.index(forKey: name) == nil {
            return false
        } else {
            return true
        }
    }
    
    func getChainOfLedger(name: String) -> Blockchain? {
        if ledgerExists(name: name) {
            return ledgers[name]!.chain
        }
        return nil
    }
}
