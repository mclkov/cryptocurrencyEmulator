//
//  Measurement.swift
//  CoinSwiftPrototype
//
//  Created by McL on 1/23/19.
//  Copyright © 2019 McL. All rights reserved.
//

import Foundation

struct Measurement {
    static func hashDifficultyEqualsTo(_ difficulty: Int, inputHash: String) -> Bool {
        return inputHash.hasPrefix(String(repeating: "0", count: difficulty))
    }
    
    static func getCurrentTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss.SSSS"
        
        return formatter.string(from: date)
    }
}
