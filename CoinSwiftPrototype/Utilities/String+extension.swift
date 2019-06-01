//
//  Swift+extension.swift
//  CoinSwiftPrototype
//
//  Created by McL on 1/5/19.
//  Copyright © 2019 McL. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    func md5sum() -> String {
        let currentContent = self + ""
        let messageData = currentContent.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        let output = digestData.map {
            String(format: "%02hhx", $0)
        }.joined()
        
        return output
    }
}
