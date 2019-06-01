//
//  LedgerLogging.swift
//  CoinSwiftPrototype
//
//  Created by McL on 5/12/19.
//  Copyright © 2019 McL. All rights reserved.
//

import Foundation

extension Ledger {
    func resetLog() {
        self.log = ""
    }
    
    func addLog(_ message: String) {
        self.log.append("\n\(message)")
    }
    
    func printBlockMessage(_ message: String) {
        let output = "\n<----------\n" + " \(ledgerName)" + "\n----------->" + "\n\(message)"
        addLog(output)
    }
    
    func printReceivedBlockAccepted(_ block: Block) {
        printBlockMessage("\(Measurement.getCurrentTime()) Accepted block:")
        printBlock(block)
    }
    
    func printValidBlock(_ block: Block) {
        printBlockMessage("\(Measurement.getCurrentTime()) Valid block:")
        printBlock(block)
    }
    
    func printRejectedBlock(_ block: Block) {
        printBlockMessage("\(Measurement.getCurrentTime()) Rejected block:")
        printBlock(block)
    }
    
    func printBlock(_ block: Block) {
        let message = "\n\nBlock nonce: \(block.nonce) (\(block.hash))" +
            "\nparent: \(block.parent?.hash)" +
            "\nrewarded: \(block.payload.coinbase.name)" +
            "\nInitiated: \(block.blockInitiated)" +
            "\nCreated: \(block.blockCreated)" +
            printTransactions(block)
        
        addLog(message)
    }
    
    func blockDebug(_ block: Block) {
        let message = "\n\nBlock nonce: \(block.nonce) (\(block.hash))" +
            "\nparent: \(block.parent?.hash)" +
            "\nrewarded: \(block.payload.coinbase.name)" +
            "\nInitiated: \(block.blockInitiated)" +
            "\nCreated: \(block.blockCreated)" +
            printTransactions(block)
        
        print(message)
        print("\n")
    }
    
    func printTransactions(_ block: Block) -> String {
        var message = "\nTransactions:\n"
        for t in block.payload.transactions {
            message.append(printTransaction(t))
        }
        return message
    }
    
    func printTransaction(_ t: Transaction) -> String {
        return "- \(t.inp.name) [\(t.inp.amount)] + \(t.out.name) [\(t.out.amount)]"
    }
    
    func printAccounts() {
        addLog("\(ledgerName) finished forming accounts out of chained blocks >>>>> --- >>>>>\n\n")
        printBlockMessage("Chain history\n\(self.accounts)\n<<>>\n<<>>\n\n")
    }
    
    func printChain() {
        print("\n\n*** \(ledgerName) chain is ***:")
        
        var currentBlock = self.chain.head
        while let next = currentBlock.parent {
            let block = next
            let message = "\n\nBlock nonce: \(block.nonce) (\(block.hash))" +
                "\nparent: \(block.parent?.hash)" +
                "\nrewarded: \(block.payload.coinbase.name)" +
                "\nInitiated: \(block.blockInitiated)" +
                "\nCreated: \(block.blockCreated)" +
                printTransactions(block)
            print(message)
            currentBlock = next
        }
    }
    
    func printLog() {
        print(self.log)
        print("*s*")
    }
}
