//
//  Blockchain.swift
//  CoinSwiftPrototype
//
//  Created by McL on 1/1/19.
//  Copyright © 2019 McL. All rights reserved.
//

import Foundation

struct Blockchain {

    var difficulty: Int
    var head: Block
    
    mutating func append(_ block: Block) -> Bool {
        let theCopy = Block(parent: head,
                            payload: block.payload,
                            nonce: block.nonce,
                            initiated: block.blockInitiated)
        theCopy.blockCreated = block.blockCreated
        theCopy.recalculateHash()
        
        guard theCopy.hasParent(block: head) else { return false }
        guard theCopy.isValidTo(difficulty: self.difficulty) else { return false }
        head = theCopy
        return true
    }
}
