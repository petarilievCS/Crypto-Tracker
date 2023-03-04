//
//  File.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 28.2.23.
//

import Foundation

struct SearchResponse: Codable {
    let count: Int
    let quotes: [SearchQuote]
}

struct SearchQuote: Codable {
    let symbol: String
    let quoteType: String 
}
