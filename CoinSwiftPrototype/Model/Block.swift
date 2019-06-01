//
//  Block.swift
//  CoinSwiftPrototype
//
//  Created by McL on 1/1/19.
//  Copyright © 2019 McL. All rights reserved.
//

import Foundation

class Block: CustomStringConvertible {
    let blockInitiated: String
    
    var stopSignal = false
    var parent: Block?
    var payload: Payload
    var nonce: Int
    var blockCreated: String = ""
    var hash: String = ""
    
    public var description: String {
        var debugInfo = "Block(parent: \(parent?.hash ?? "nil"), "
        debugInfo.append("payload: \(payload), nonce: \(nonce), ")
        debugInfo.append("hash: \(recalculatedHash()))")
        return debugInfo
    }
    
    init(parent: Block?, payload: Payload, nonce: Int = 0,
         initiated: String = Measurement.getCurrentTime()) {
        
        self.blockInitiated = Measurement.getCurrentTime()
        self.parent = parent
        self.payload = payload
        self.nonce = nonce
    }
    
}

extension Block {
    private func isValidTo(difficulty: Int, inputHash: String) -> Bool {
        return Measurement.hashDifficultyEqualsTo(difficulty, inputHash: inputHash)
    }
    
    private func updateBlockCreated() {
        self.blockCreated = Measurement.getCurrentTime()
    }
    
    private func setHash(_ newhash: String) {
        self.hash = newhash
    }
    
    private func calculateHash(foundNonce: Int) -> String {
        let content = (String(describing: parent?.recalculatedHash())
            + payload.payloadHash
            + String(describing: foundNonce))
        return content.md5sum()
    }
    
    func receivedBlockIsValid(foundNonce: Int, difficulty: Int) -> Bool {        
        let blockHash = calculateHash(foundNonce: foundNonce)
        return isValidTo(difficulty: difficulty, inputHash: blockHash)
    }
    
    func isValidTo(difficulty: Int) -> Bool {
        return isValidTo(difficulty: difficulty, inputHash: self.hash)
    }
    
    func mineBlock(difficulty: Int) -> Self {
        for i in 0...Int.max {
            if stopSignal == true {
                print("stopped mining cycle, nonce: \(i)\n\(self)")
                return self
            }
            
            self.nonce = i
            updateBlockCreated()
            
            let calculatedHash = self.calculateHash(foundNonce: i)
            if isValidTo(difficulty: difficulty, inputHash: calculatedHash) {
                self.setHash(calculatedHash)
                return self
            }
        }
        fatalError("Could not find proof of work")
    }
    
    func mineInvalidBlock(difficulty: Int) -> Self {
        for i in 0...Int.max {
            if stopSignal == true {
                print("stopped mining cycle, nonce: \(i)\n\(self)")
                return self
            }
            
            self.nonce = i
            updateBlockCreated()
            
            let calculatedHash = self.calculateHash(foundNonce: i)
            if !isValidTo(difficulty: difficulty, inputHash: calculatedHash) {
                self.setHash(calculatedHash)
                return self
            }
        }
        fatalError("Could not find proof of work")
    }
    
    func invalidMining(for chain: Blockchain) -> Self {
        let chainDifficulty = chain.difficulty
        return self.mineInvalidBlock(difficulty: chainDifficulty)
    }
    
    func mineGenesis(initialDifficulty: Int) -> Self {
       return self.mineBlock(difficulty: initialDifficulty)
    }
    
    func mine(for chain: Blockchain) -> Self {
        let chainDifficulty = chain.difficulty
        return self.mineBlock(difficulty: chainDifficulty)
    }
    
    func hasParent(block: Block) -> Bool {
        if let parentBlock = self.parent {
            if parentBlock.recalculatedHash() == block.recalculatedHash() {
                return true
            }
        }
        return false
    }
    
    func recalculatedHash() -> String {
        return calculateHash(foundNonce: nonce)
    }
    
    func recalculateHash() {
        setHash(recalculatedHash())
    }
}
