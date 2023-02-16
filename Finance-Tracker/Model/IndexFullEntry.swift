//
//  IndexFullEntry.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 16.2.23.
//

import Foundation

struct QuoteResponse: Codable {
    let quoteResponse: ResponseResult
}

struct ResponseResult: Codable {
    let result: [IndexFullEntry]
}

struct IndexFullEntry: Codable {
    let shortName: String?
    let symbol: String
    let regularMarketChangePercent: Double?
    let regularMarketPrice: Double?
    let regularMarketOpen: Double?
    let regularMarketVolume: Double?
    let regularMarketPreviousClose: Double?
    let regularMarketDayLow: Double?
    let regularMarketDayHigh: Double?
}
