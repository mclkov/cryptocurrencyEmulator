//
//  NetworkTest.swift
//  CoinPrototypeTest
//
//  Created by McL on 4/24/19.
//  Copyright © 2019 McL. All rights reserved.
//

import XCTest

class NetworkTest: XCTestCase {
    let localNodes = [
        "left blank intentionally",
        "10.0.32.1",
        "10.0.32.2",
        "10.0.32.3",
        "10.0.32.4"]
    
    func test_1_CalculateAmountOfBlocks1() {
        // Assert
        let nodes = localNodes
        let network = NodeNetwork()
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateLedger(name: nodes[2], lookForLongest: true)
        
        // Act
        let queryFromNode = network.ledgers[nodes[2]]!
        let node1AmountOfValidBlocks = queryFromNode.calculateValidBlocksOf(externalChain: network.ledgers[nodes[1]]!.chain)
        let node2AmountOfValidBlocks = queryFromNode.calculateValidBlocksOf(externalChain: network.ledgers[nodes[2]]!.chain)
        
        // Assess
        let chainOfNode1 = network.getChainOfLedger(name: nodes[1])!
        let chainOfNode2 = network.getChainOfLedger(name: nodes[2])!
        
        let node1LastBlockOwner = chainOfNode1.head.payload.coinbase.name
        let node2LastBlockOwner = chainOfNode2.head.payload.coinbase.name
        
        XCTAssertTrue(node1AmountOfValidBlocks == 1 &&
            node2AmountOfValidBlocks == 1 &&
            node1LastBlockOwner == node2LastBlockOwner)
    }
    
    func test_2_CalculateAmountOfBlocks2() {
        // Assert
        let nodes = localNodes
        let network = NodeNetwork()
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateBlockForLedger(name: nodes[1])
        
        // Act
        network.generateLedger(name: nodes[2], lookForLongest: true)
        let queryFromNode = network.ledgers[nodes[2]]!
        let node1AmountOfValidBlocks = queryFromNode.calculateValidBlocksOf(externalChain: network.ledgers[nodes[1]]!.chain)
        let node2AmountOfValidBlocks = queryFromNode.calculateValidBlocksOf(externalChain: network.ledgers[nodes[2]]!.chain)
        
        // Assess
        let chainOfNode1 = network.getChainOfLedger(name: nodes[1])!
        let chainOfNode2 = network.getChainOfLedger(name: nodes[2])!
        
        let node1LastBlockOwner = chainOfNode1.head.payload.coinbase.name
        let node2LastBlockOwner = chainOfNode2.head.payload.coinbase.name
        
        XCTAssertTrue(node1AmountOfValidBlocks == 2 &&
            node2AmountOfValidBlocks == 2 &&
            node1LastBlockOwner == node2LastBlockOwner)
    }
    
    func test_3_LedgersAreEqualFail () {
        // Assert
        let nodes = localNodes
        let network = NodeNetwork()
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateLedger(name: nodes[2], lookForLongest: false)
        
        // Act
        let ledger2 = network.ledgers[nodes[2]]!
        let ledgersEqual = network.ledgers[nodes[1]]!.equalTo(ledger: ledger2)
        
        // Assess
        XCTAssertFalse(ledgersEqual)
    }
    
    func test_4_LedgersAreEqualTrue () {
        // Assert
        let nodes = localNodes
        let network = NodeNetwork()
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateLedger(name: nodes[2], lookForLongest: true)
        
        // Act
        let ledger2 = network.ledgers[nodes[2]]!
        let ledgersEqual = network.ledgers[nodes[1]]!.equalTo(ledger: ledger2)
        
        // Assess
        XCTAssertTrue(ledgersEqual)
    }
    
    func test_5_GetLongestChainOnBoot() {
        // Assert
        let nodes = localNodes
        let network = NodeNetwork()
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateBlockForLedger(name: nodes[1])
        network.generateBlockForLedger(name: nodes[1])
        network.generateBlockForLedger(name: nodes[1])
        
        network.generateLedger(name: nodes[2], lookForLongest: false)
        network.generateBlockForLedger(name: nodes[2])
        network.generateBlockForLedger(name: nodes[2])
        network.generateBlockForLedger(name: nodes[2])
        network.generateBlockForLedger(name: nodes[2])
        
        network.generateLedger(name: nodes[3], lookForLongest: false)
        network.generateBlockForLedger(name: nodes[3])
        network.generateBlockForLedger(name: nodes[3])
        
        // Act
        network.generateLedger(name: nodes[4], lookForLongest: true)
        let chainOf4thNode = network.ledgers[nodes[4]]!.chain
        let node1 = network.ledgers[nodes[1]]!
        let queryFrom2ndNode = node1.calculateValidBlocksOf(externalChain: chainOf4thNode)
        
        // Assess
        XCTAssertTrue(queryFrom2ndNode == 5)
    }
    
    func test_6_GetLongestChainOnTheFly() {
        // Assert
        let nodes = localNodes
        let network = NodeNetwork()
        
        network.generateLedger(name: nodes[1], lookForLongest: true) //1
        network.generateBlockForLedger(name: nodes[1]) //2
        
        network.generateLedger(name: nodes[2], lookForLongest: false)
        
        network.generateLedger(name: nodes[3], lookForLongest: false)
        
        // Act
        network.generateBlockForLedger(name: nodes[1]) //3
        let node1 = network.ledgers[nodes[1]]!
        
        let chainOf2ndNode = network.ledgers[nodes[2]]!.chain
        let chainOf3rdNode = network.ledgers[nodes[3]]!.chain
        
        let queryFrom1stNodeTo2 = node1.calculateValidBlocksOf(externalChain: chainOf2ndNode)
        let queryFrom1stNodeTo3 = node1.calculateValidBlocksOf(externalChain: chainOf3rdNode)
        
        // Assess
        XCTAssertTrue(queryFrom1stNodeTo2 == 3 &&
            queryFrom1stNodeTo3 == 3)
    }
    
    func test_7_NetworkStabilizesItselfAsync() {
        // Assert
        let nodes = localNodes
        let concurrentQueue = DispatchQueue(
            label: "serialQueue",
            attributes: .concurrent)
        let taskGroup = DispatchGroup()
        let network = NodeNetwork()
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateBlockForLedger(name: nodes[1])
        
        network.generateLedger(name: nodes[2], lookForLongest: true)
        
        network.generateLedger(name: nodes[3], lookForLongest: true)
        
        // Act
        concurrentQueue.async(group: taskGroup) {
            print("Node 2 init: \(Measurement.getCurrentTime())")
            network.generateBlockForLedger(name: nodes[2])
        }
        
        concurrentQueue.async(group: taskGroup) {
            print("Node 3 init: \(Measurement.getCurrentTime())")
            network.generateBlockForLedger(name: nodes[3])
        }
        
        // Assert
        taskGroup.wait()
        network.generateBlockForLedger(name: nodes[2])
        
        let node1 = network.ledgers[nodes[1]]!
        let node2 = network.ledgers[nodes[2]]!
        let node3 = network.ledgers[nodes[3]]!
        
        XCTAssertTrue(node1.equalTo(ledger: node2) &&
            node2.equalTo(ledger: node3))
    }
    
    func test_8_3NodesWhere2ndChangesPayloadAndSendsToOthersSuccessfulAttack() {
        let userOfFakedBlock = "UserOfFakedBlock"
        let nodes = localNodes
        let network = NodeNetwork()
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateBlockForLedger(name: nodes[1], extraTransaction: Transaction(
            inp: TransactionData(name: nodes[1], amount: 10),
            out: TransactionData(name: nodes[2], amount: 10)))
        
        network.generateLedger(name: nodes[2], lookForLongest: true)
        
        network.generateLedger(name: nodes[3], lookForLongest: true)
        
        network.generateBlockForLedger(name: nodes[2])
        
        // Act
        network.ledgers[nodes[2]]!.chain.head.payload.transactions = [
            Transaction(
                inp: TransactionData(name: nodes[2], amount: 10),
                out: TransactionData(name: userOfFakedBlock, amount: 10))]
        
        let currentDifficulty = network.ledgers[nodes[2]]!.chain.difficulty
        network.ledgers[nodes[2]]!.chain.head.mineBlock(difficulty: currentDifficulty)
        network.generateBlockForLedger(name: nodes[2])
        
        // Assert
        let fakedUserBalanceNode1 = network.ledgers[nodes[1]]!.getAccountBalance(name: userOfFakedBlock)
        let fakedUserBalanceNode2 = network.ledgers[nodes[2]]!.getAccountBalance(name: userOfFakedBlock)
        let fakedUserBalanceNode3 = network.ledgers[nodes[3]]!.getAccountBalance(name: userOfFakedBlock)
        
        var attackSucceed = false
        if fakedUserBalanceNode1 == 10 &&
            fakedUserBalanceNode2 == fakedUserBalanceNode1 &&
            fakedUserBalanceNode2 == fakedUserBalanceNode3 {
            attackSucceed = true
        }
        XCTAssertTrue(attackSucceed)
    }
    
    func test_9_NodeCanMineInvalidBlock() {
        // Assert
        let userOfFakedBlock = "UserOfInvalidBlock"
        
        let nodes = localNodes
        let network = NodeNetwork()
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateBlockForLedger(name: nodes[1])
        
        let currentDifficulty = network.ledgers[nodes[1]]!.chain.difficulty
        
        // Act
        let invalidBlock = network.generateInvalidBlockForLedger(name: nodes[1], extraTransaction:
            Transaction(
                inp: TransactionData(name: nodes[1], amount: 10),
                out: TransactionData(name: userOfFakedBlock, amount: 10)))
        
        // Assert
        let blockIsValid = invalidBlock.isValidTo(difficulty: currentDifficulty)
        network.ledgers[nodes[1]]!.printLog()
        
        XCTAssertFalse(blockIsValid)
    }
    
    func test_10_NetworkRejectsInvalidBlock() {
        // Assert
        let userOfFakedBlock = "UserOfInvalidBlock"
        
        let nodes = localNodes
        let network = NodeNetwork()
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateBlockForLedger(name: nodes[1])
        
        network.generateLedger(name: nodes[2], lookForLongest: true)
        
        network.generateLedger(name: nodes[3], lookForLongest: true)
        
        // Act
        network.generateInvalidBlockForLedger(name: nodes[1], extraTransaction:
            Transaction(
                inp: TransactionData(name: nodes[1], amount: 10),
                out: TransactionData(name: userOfFakedBlock, amount: 10)))
        
        // Assert
        let node1 = network.ledgers[nodes[1]]!
        let node2 = network.ledgers[nodes[2]]!
        let node3 = network.ledgers[nodes[3]]!
        
        let queryFromNode1 = node1.getAccountBalance(name: userOfFakedBlock)
        let queryFromNode2 = node2.getAccountBalance(name: userOfFakedBlock)
        let queryFromNode3 = node3.getAccountBalance(name: userOfFakedBlock)
        
        var invalidBlockRejected = false
        if queryFromNode1 == 0 &&
            queryFromNode2 == queryFromNode1 &&
            queryFromNode2 == queryFromNode3 {
            invalidBlockRejected = true
        }
        
        XCTAssertTrue(invalidBlockRejected)
    }
    
    func test_11_validTransactionAppearsInNetwork() {
        // Assert
        let nodes = localNodes
        let network = NodeNetwork()
        let newUser = "Bob"
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateLedger(name: nodes[2], lookForLongest: true)
        
        network.generateBlockForLedger(name: nodes[1], extraTransaction: Transaction(
            inp: TransactionData(name: nodes[1], amount: 10),
            out: TransactionData(name: newUser, amount: 10)))

        
        // Act
        let node2 = network.ledgers[nodes[2]]!
        let balanceOfBob = node2.getAccountBalance(name: newUser)
        
        // Assess
        XCTAssertTrue(balanceOfBob == 10)
    }

    func test_12_invalidTransactionDoesNotAppearInNetwork() {
        // Assert
        let nodes = localNodes
        let network = NodeNetwork()
        let newUser = "Bob"
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateLedger(name: nodes[2], lookForLongest: true)
        
        network.generateBlockForLedger(name: nodes[1], extraTransaction: Transaction(
            inp: TransactionData(name: nodes[1], amount: 200),
            out: TransactionData(name: newUser, amount: 200)))
        
        print(network.getChainOfLedger(name: nodes[1])!.head)
        // Act
        let balanceOfBob = network.ledgers[nodes[2]]!.getAccountBalance(name: newUser)
        
        // Assess
        XCTAssertTrue(balanceOfBob == 0)
    }
    
    func test_13_NetworkStabilizesItselfAsyncInvalidBlockScenario() {
        // Assert
        let nodes = localNodes
        let concurrentQueue = DispatchQueue(
            label: "serialQueue",
            attributes: .concurrent)
        let taskGroup = DispatchGroup()
        let network = NodeNetwork()
        
        network.generateLedger(name: nodes[1], lookForLongest: true)
        network.generateBlockForLedger(name: nodes[1])
        
        network.generateLedger(name: nodes[2], lookForLongest: true)
        
        network.generateLedger(name: nodes[3], lookForLongest: true)
        
        // Act
        concurrentQueue.async(group: taskGroup) {
            print("Node 2 init: \(Measurement.getCurrentTime())")
            network.generateBlockForLedger(name: nodes[2])
        }
        
        concurrentQueue.async(group: taskGroup) {
            print("Node 3 init: \(Measurement.getCurrentTime())")
            network.generateInvalidBlockForLedger(name: nodes[3])
        }
        
        // Assert
        taskGroup.wait()
        network.generateBlockForLedger(name: nodes[2])
        
        let node1 = network.ledgers[nodes[1]]!
        let node2 = network.ledgers[nodes[2]]!
        let node3 = network.ledgers[nodes[3]]!
        
        XCTAssertTrue(node1.equalTo(ledger: node2) &&
            node2.equalTo(ledger: node3))
    }
}
