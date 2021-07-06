//
//  URLGenerator.swift
//  
//
//  Created by Luke Davis on 7/5/21.
//

import Foundation

extension URL {
    
    // MARK: - Scheme
    static func generateValidScheme() -> String {
        // Ensure conformance to RFC-2396 https://www.ietf.org/rfc/rfc2396.txt
        let validFirstSymbol = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        return "\(validFirstSymbol.randomElement()!)\(UUID().uuidString)"
    }
    
    static func generateInvalidScheme() -> String {
        return "\(Int.random(in: 0...9))\(generateValidScheme())"
    }
}


