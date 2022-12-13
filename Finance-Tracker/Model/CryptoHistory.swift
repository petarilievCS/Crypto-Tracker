//
//  CryptoHistory.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 13.12.22.
//

struct CryptoHistory: Codable {
    let quotes: [CryptoQuote]
}

struct CryptoQuote: Codable {
    let rate_open: Double
}
