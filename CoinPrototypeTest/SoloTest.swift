//
//  CoinPrototypeTest.swift
//  CoinPrototypeTest
//
//  Created by McL on 1/1/19.
//  Copyright © 2019 McL. All rights reserved.
//

import XCTest

class SoloTest: XCTestCase {
    
    func test_1_NoDifficulty() {
        let hashValue = "30c016ff3eeae61d43f9aa6adecc2b7d"
        XCTAssertTrue(Measurement.hashDifficultyEqualsTo(0, inputHash: hashValue))
    }
    
    func test_2_HashCorrespondsDifficultySuccess () {
        let hashValue = "000f6bcd4621d373cade4e832627b4f6"
        XCTAssertTrue(Measurement.hashDifficultyEqualsTo(3, inputHash: hashValue))
    }
    
    func test_3_HashCorrespondsDifficultyFailure () {
        let hashValue = "008f6bcd4621d373cade4e832627b4f60"
        XCTAssertFalse(Measurement.hashDifficultyEqualsTo(3, inputHash: hashValue))
    }
    
    func test_4_CanCreateGenesisBlock () {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        let alice = network.ledgers["Alice"]!
        
        // Act
        let chain = network.getChainOfLedger(name: "Alice")!
        let headBlock = chain.head
        let balanceOfAlice = alice.getAccountBalance(name: "Alice")
        let validBlocks = alice.calculateValidBlocksOf(externalChain: chain)
        
        // Assess
        XCTAssertTrue(headBlock.parent == nil && balanceOfAlice == 100 && validBlocks == 1)
    }
    
    func test_5_InitialDifficultyEquals2 () {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        
        let chain = network.getChainOfLedger(name: "Alice")!
        let genesisBlock = chain.head
        
        print(chain.head.hash)
        
        // Act
        let hasDifficultyEquals2 = genesisBlock.isValidTo(difficulty: 2)
        
        // Assess
        XCTAssertTrue(hasDifficultyEquals2)
    }
    
    func test_6_IfPayloadWasModifiedFails() {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        network.generateBlockForLedger(name: "Alice")
        
        let ledger = network.ledgers["Alice"]!
        
        // Act
        ledger.chain.head.payload = Payload(coinbase:
            TransactionData(name: ledger.ledgerName, amount: 100))
        let chain = ledger.chain
        let headBlock = chain.head
        let nonce = ledger.chain.head.nonce
        let blockIsValid = headBlock.receivedBlockIsValid(foundNonce: nonce,
                                                          difficulty: chain.difficulty)
        
        // Assert
        XCTAssertFalse(blockIsValid)
    }
    
    func test_7_IfPreviousBlockWasModifiedWithNoReminingFails() {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        
        // genesis block + 1st block
        network.generateBlockForLedger(name: "Alice")
        
        // 2nd block
        network.generateBlockForLedger(name: "Alice")
        
        let ledger = network.ledgers["Alice"]!
        
        // Act
        ledger.chain.head.parent!.payload = Payload(coinbase:
            TransactionData(name: ledger.ledgerName, amount: 100))
        let block1 = ledger.chain.head.parent!
        let block2 = ledger.chain.head
        
        let block1IsValid = ledger.blockValidator(block1)
        let block2IsValid = ledger.blockValidator(block2)
        
        // Assess
        XCTAssertFalse(block1IsValid && block2IsValid)
    }
    
    func test_8_UnexistedAccountEqualsZero() {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        
        let ledger = network.ledgers["Alice"]!
        
        // Act
        let noNameBalance = ledger.getAccountBalance(name: "NoName")
        let aliceBalance = ledger.getAccountBalance(name: "Alice")
        
        // Assert
        XCTAssertTrue(noNameBalance == 0.0 && aliceBalance == 100.0)
    }
    
    func test_9_ValidateTransactionsTrue() {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        
        let ledger = network.ledgers["Alice"]!
    
        // Act
        ledger.mining(transactions: [
            Transaction(
                inp: TransactionData(name: ledger.ledgerName, amount: 20),
                out: TransactionData(name: "Liz", amount: 20)),
            Transaction(
                inp: TransactionData(name: ledger.ledgerName, amount: 30),
                out: TransactionData(name: "Tom", amount: 30))
            ])
        
        ledger.printLog()
        
        // Assert
        XCTAssertTrue(ledger.getAccountBalance(name: "Liz") == 20 &&
            ledger.getAccountBalance(name: "Tom") == 30)
    }
    
    func test_10_ValidateTransactionsFalse() {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        
        let ledger = network.ledgers["Alice"]!
        
        // Act
        ledger.mining(transactions: [
            Transaction(
                inp: TransactionData(name: ledger.ledgerName, amount: 120),
                out: TransactionData(name: "Liz", amount: 120)),
            Transaction(
                inp: TransactionData(name: ledger.ledgerName, amount: 30),
                out: TransactionData(name: "Tom", amount: 30))
            ])
        
        ledger.blockDebug(network.ledgers["Alice"]!.chain.head)
        
        // Assert
        XCTAssertTrue(ledger.getAccountBalance(name: "Liz") == 0 &&
            ledger.getAccountBalance(name: "Tom") == 30 &&
            ledger.getAccountBalance(name: "Alice") == 170
        )
    }
    
    func test_11_IfPreviousBlockWasModifiedHashJustClaimedNotMinedFails() {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        let ledger = network.ledgers["Alice"]!
        
        // genesis block + 1st block
        network.generateBlockForLedger(name: "Alice")
        
        // 2nd block
        network.generateBlockForLedger(name: "Alice")
        
        // Act
        let fakedPayload = Payload(coinbase:
            TransactionData(name: ledger.ledgerName, amount: 100))
        ledger.chain.head.parent!.payload = fakedPayload
        ledger.chain.head.parent!.hash = "00sThisJustFakedHash1832627b4f60"

        // Assess
        let block1 = ledger.chain.head.parent!
        let block2 = ledger.chain.head
        
        let block1IsValid = ledger.blockValidator(block1)
        let block2IsValid = ledger.blockValidator(block2)
        
        XCTAssertFalse(block1IsValid && block2IsValid)
        
        ledger.resetLog()
        ledger.applyChainChanges()
        ledger.printLog()
    }
    
    func test_12_BlockHasParentFail () {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        
        let ledger = network.ledgers["Alice"]!
        let chain = ledger.chain
        
        // genesis block + 1st block
        network.generateBlockForLedger(name: "Alice")
        
        // Act
        let notParentBlock = Block(parent: nil, payload:
            Payload(coinbase:
                TransactionData(name: "test", amount: 10)))
        let hasParentBlock = chain.head.hasParent(block: notParentBlock)
        
        // Assess
        XCTAssertFalse(hasParentBlock)
    }
    
    func test_13_BlockHasForgedParentSuccess () {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        
        let ledger = network.ledgers["Alice"]!
        
        // genesis block + 1st block
        network.generateBlockForLedger(name: "Alice")
        
        // Act
        ledger.chain.head.parent!.payload.transactions = [
            Transaction(
                inp: TransactionData(name: ledger.ledgerName, amount: 20),
                out: TransactionData(name: "Liz", amount: 20))]
        let forgedBlock = ledger.chain.head.parent!
        let hasParentBlock = ledger.chain.head.hasParent(block: forgedBlock)
        
        // Assess
        XCTAssertTrue(hasParentBlock)
    }
    
    func test_14_BlockHasParentSuccess () {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        
        let ledger = network.ledgers["Alice"]!
        let genesisBlock = ledger.chain.head
        
        // genesis block + 1st block
        network.generateBlockForLedger(name: "Alice")
        
        // Act
        let hasParentBlock = ledger.chain.head.hasParent(block: genesisBlock)
        
        // Assess
        XCTAssertTrue(hasParentBlock)
    }
    
    func test_15_canFilterInvalidTransactionsWhenSenderDoesNotExist() {
        // Assert
        let filteredUserName = "ReceiverOfInvalidTransaction"
        let network = NodeNetwork()
        network.createLedgerAlice()
        
        let ledger = network.ledgers["Alice"]!
    
        // Act
        ledger.mining(transactions: [
            Transaction(
                inp: TransactionData(name: ledger.ledgerName, amount: 20),
                out: TransactionData(name: "Liz", amount: 20)),
            Transaction(
                inp: TransactionData(name: filteredUserName, amount: 100),
                out: TransactionData(name: "Dave", amount: 100))
            ])
        
        // Assert
        XCTAssertTrue(ledger.getAccountBalance(name: "Dave") == 0 &&
            ledger.getAccountBalance(name: "Liz") == 20)
    }
    
    func test_16_canFilterInvalidTransactionsUnbalance() {
        // Assert
        let network = NodeNetwork()
        network.createLedgerAlice()
        let ledger = network.ledgers["Alice"]!
        
        // Act
        ledger.mining(transactions: [
            Transaction(
                inp: TransactionData(name: ledger.ledgerName, amount: 20),
                out: TransactionData(name: "Liz", amount: 100))
            ])
        
        // Assert
        XCTAssertTrue(ledger.getAccountBalance(name: "Liz") == 0)
    }
    
    func testTemplate () {
        // Assert
        
        // Act
        
        // Assess
    }
}
