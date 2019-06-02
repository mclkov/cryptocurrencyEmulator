//
//  Ledger.swift
//  CoinSwiftPrototype
//
//  Created by McL on 1/3/19.
//  Copyright © 2019 McL. All rights reserved.
//

import Foundation

class Ledger {
    let ledgerName: String
    
    var log: String = ""
    var accounts: [String: Double] = [:]
    var chain: Blockchain
    var blocks: [Block]
    var blockInProgress: Block?
    
    init(name: String, difficulty: Int) {
        let payloadTransaction = TransactionData(name: name, amount: 100)
        let payload = Payload(coinbase: payloadTransaction)
        let genesisBlock = Block(parent: nil, payload: payload)
        let minedBlock = genesisBlock.mineGenesis(initialDifficulty: difficulty)
        
        self.ledgerName = name
        self.chain = Blockchain(
            difficulty: difficulty,
            head: minedBlock)
        self.blocks = [chain.head]
        setup()
    }
}

extension Ledger {
    private func setup() {
        addLog("\n\n\(Measurement.getCurrentTime()) <<<< --- <<<<< \(ledgerName) starts forming accounts out of chained blocks:")
        recalculateBalance()
    }
    
    private func recalculateBalance() {
        self.accounts = [:]
        self.blocks = [chain.head]
        
        var currentBlock = self.chain.head
        while let next = currentBlock.parent {
            self.blocks.append(next)
            currentBlock = next
        }
        
        self.validateBlocks()
    }
    
    private func validateBlocks() {
        for block in blocks.reversed() {
            if blockIsValid(block) {
                printValidBlock(block)
                processTransactions(block)
            } else {
                printRejectedBlock(block)
            }
        }
        printAccounts()
    }
    
    private func blockIsValid(_ block: Block) -> Bool {
        let chainDifficulty = self.chain.difficulty
        let payload = block.payload
        let claimedHashIsValid = block.isValidTo(difficulty: chainDifficulty)
        
        guard claimedHashIsValid else {
            return false
        }
        guard block.receivedBlockIsValid(foundNonce: block.nonce, difficulty: chainDifficulty) else {
            addLog("Incorrect nonce: \(block.nonce) for \n claimed hash: \(block.hash) \n actual hash: \(block.recalculatedHash())")
            return false
        }
        guard payload.coinbase.amount == 100 else {
            addLog("Invalid coinbase amount")
            return false
        }
        
        return true
    }
    
    private func processTransactions(_ block: Block) {
        let payload = block.payload
        
        rewardBlockCreator(payload: payload)
        validateTransactions(transactions: payload.transactions)
    }
    
    private func rewardBlockCreator(payload: Payload) {
        accounts[payload.coinbase.name] = (accounts[payload.coinbase.name] ?? 0.0) + payload.coinbase.amount
    }
    
    private func validateTransactions(transactions: [Transaction]) {
        for transaction in transactions {
            validateTransaction(transaction)
        }
    }
    
    private func validateTransaction(_ t: Transaction) {
        if transactionIsValid(transaction: t) {
            accounts[t.inp.name] = accounts[t.inp.name]! - t.inp.amount
            accounts[t.out.name] = (accounts[t.out.name] ?? 0) + t.out.amount
        }
    }
    
    private func transactionIsValid(transaction t: Transaction) -> Bool {
        guard t.inp.amount == t.out.amount else {
            addLog("\n\(ledgerName): Transaction rejected\nUnbalanced transaction: \(t)\n")
            return false
        }
        guard let inBalance = accounts[t.inp.name], inBalance >= t.inp.amount else {
            addLog("\n\(ledgerName): Transaction rejected\nOverspend: \(t.inp.name) spent \(t.inp.amount), but has \(accounts[t.inp.name] ?? 0)")
            return false
        }
        
        return true
    }
    
    private func createCurrentBlock() -> Block {
        return Block(
            parent: chain.head,
            payload: Payload(
                coinbase: TransactionData(name: self.ledgerName, amount: 100)))
    }
    
    private func stopMining() {
        self.blockInProgress?.stopSignal = true
    }
    
    private func filterInvalidTransactions(transactions: [Transaction]) -> [Transaction] {
        var result = [Transaction]()
        for t in transactions {
            if transactionIsValid(transaction: t) {
                result.append(t)
            }
        }
        return result
    }
    
    func equalTo(ledger: Ledger) -> Bool {
        let accountLedger = ledger.accounts
        for (name, amount) in accounts {
            if accountLedger[name] != amount {
                return false
            }
        }
        return true
    }
    
    func setChain(_ newchain: Blockchain) {
        self.accounts = [:]
        self.chain = newchain
        self.blocks = [chain.head]
        setup()
    }
    
    func processReceivedBlockAndStopMining(_ block: Block) {
        let currentDifficulty = self.chain.difficulty
        if block.receivedBlockIsValid(foundNonce: block.nonce, difficulty: currentDifficulty) {
            addLog("\(Measurement.getCurrentTime()) \(ledgerName) received signal to stop mining \n new block is: \(block)")
            stopMining()
            updateChainWithReceived(newBlock: block)
        } else {
            addLog("\(Measurement.getCurrentTime()) \(ledgerName) received signal to stop mining \n invalid block is: \(block)")
        }
    }
    
    func updateChainWithReceived(newBlock: Block) {
        if blockIsValid(newBlock) {
            if self.chain.append(newBlock) {
                printReceivedBlockAccepted(newBlock)
                setup()
            }
        }
    }
    
    func miningInvalidBlock(transactions: [Transaction]) -> Block {
        self.blockInProgress = createCurrentBlock()
        
        let validTransactions = filterInvalidTransactions(transactions: transactions)
        blockInProgress!.payload.addTransactions(validTransactions)
        let minedBlock = blockInProgress!.invalidMining(for: chain)
        
        if minedBlock.stopSignal == false {
            updateChainWithReceived(newBlock: minedBlock)
        }
        return minedBlock
    }
    
    func mining(transactions: [Transaction]) -> Block {
        self.blockInProgress = createCurrentBlock()
        
        let validTransactions = filterInvalidTransactions(transactions: transactions)
        blockInProgress!.payload.addTransactions(validTransactions)
        let minedBlock = blockInProgress!.mine(for: chain)
        
        if minedBlock.stopSignal == false {
            updateChainWithReceived(newBlock: minedBlock)
        }
        return minedBlock
    }
    
    func calculateValidBlocksOf(externalChain: Blockchain) -> Int {
        var amount = 1
        var blocksArray = [Block]()
        var currentBlock = externalChain.head
        while let next = currentBlock.parent {
            blocksArray.append(next)
            currentBlock = next
        }
        
        for block in blocksArray.reversed() {
            if blockIsValid(block) {
                amount = amount + 1
            }
        }
        
        return amount
    }
    
    func getAccountBalance(name: String) -> Double {
        if let balance = self.accounts[name] {
            return balance
        }
        return 0.0
    }
    
    func applyChainChanges() {
        recalculateBalance()
    }
    
    func blockValidator(_ block: Block) -> Bool {
        return blockIsValid(block)
    }
    
    func interruptMining() {
        stopMining()
    }
}
