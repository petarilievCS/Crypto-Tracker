//
//  ChartDataModel.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 21.2.23.
//

import Foundation

struct ChartDataModel: Codable {
    let chart: ChartModel
}

struct ChartModel: Codable {
    let result: [ChartResult]
}

struct ChartResult: Codable {
    let timestamp: [Int]
    let indicators: ChartIndicator
}

struct ChartIndicator: Codable {
    let quote: [ChartQuote]
}

struct ChartQuote: Codable {
    let close: [Double?]
}
