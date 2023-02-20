//
//  stockManager.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 24.1.23.
//

import Foundation
import SwiftYFinance

protocol StockManagerDelegate {
    func receivedStockInformation()
    func receivedSymbolInformatioN(for symbol: RecentStockData)
    func receivedSymbolMetrics(for symbol: StockChartData)
    func receivedChartData(for data: [StockChartData])
}

class StockManager {
    
    var indexFundEntries: [IndexEntry] = []
    var indexFundFullEntries: [IndexFullEntry] = []
    var delegate: StockManagerDelegate?
    
    // Set containing all stocks which have the same symbol as a crypto currency
    var edgeCaseSet: Set<String> = ["abt", "amp", "t", "blk", "cvx", "etn", "d", "mco", "oxy", "payx", "stx", "tel"]
    
    // Performs API request in order to obtain list of NASDAQ companies
    func performRequest() {
        if let url = Bundle.main.url(forResource: "constituents_json", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                indexFundEntries = try decoder.decode([IndexEntry].self, from: data)
                self.performPricesRequest()
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    // Perform API request for company prices
    func performPricesRequest() {
        var urlString = "https://query1.finance.yahoo.com/v7/finance/quote?symbols="
        for indexFundEntry in indexFundEntries {
            urlString += indexFundEntry.Symbol + ","
        }
        urlString.removeLast()
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error while performing request: \(error!)")
            }
            if let safeData = data {
                self.parsePricesJSON(from: safeData)
            }
        }
        task.resume()
    }
    
    // Parses JSON response from Yahoo Finance
    func parsePricesJSON(from data: Data) {
        let decoder = JSONDecoder()
        do {
            indexFundFullEntries = try decoder.decode(QuoteResponse.self, from: data).quoteResponse.result
            delegate?.receivedStockInformation()
        } catch {
            print("Error while decoding index entries: \(error)")
        }
    }
    
    // Return basic info for given symbol
    func getInfo(for symbol: String) {
        SwiftYFinance.recentDataBy(identifier: symbol) { data, error in
            if error == nil {
                if let safeData = data {
                    self.delegate?.receivedSymbolInformatioN(for: safeData)
                }
            } else {
                print(data!.regularMarketPrice ?? "No regularMarketPrice")
            }
        }
    }
    
    // Calculates percent change of given stock
    func getPercentChange(for stock: RecentStockData) -> Float {
        if let previousClose = stock.previousClose, let currentPrice = stock.regularMarketPrice {
            let difference = currentPrice - previousClose
            let percentChange = previousClose / (difference * 100.0)
            return percentChange
        }
        return 0.0
    }
    
    // Get metrics for given stock
    func getMetrics(for symbol: String) {
        let today = Date.now
        
        SwiftYFinance.chartDataBy(identifier: symbol, start: Calendar.current.date(byAdding: .day, value: -1, to: today)!, end: Date.now, interval: .oneday) { data, error in
            if error == nil {
                if let safeData = data {
                    self.delegate?.receivedSymbolMetrics(for: safeData[0])
                } else {
                    print("Error: Invalid data")
                }
            } else {
                print(data![0].open ?? "Open price is unavailable")
            }
        }
    }
    
    
    // Get chart data for given stock
    func performChartDataRequest(for symbol: String, in period: Period) {
        let today = Date.now
        var timePeriod: Calendar.Component?
        var numberOfPeriod: Int = 0
        var interval: ChartTimeInterval?
        
        switch period {
        case .day:
            timePeriod = .day
            numberOfPeriod = 1
            interval = .fifteenminutes
        case .fiveDays:
            timePeriod = .day
            numberOfPeriod = 5
            interval = .onehour
        case .month:
            timePeriod = .month
            numberOfPeriod = 1
            interval = .oneday
        case .threeMonths:
            timePeriod = .month
            numberOfPeriod = 3
            interval = .oneday
        case .sixMonths:
            timePeriod = .month
            numberOfPeriod = 6
            interval = .fivedays
        case .year:
            timePeriod = .year
            numberOfPeriod = 1
            interval = .fivedays
        case .twoYears:
            timePeriod = .year
            numberOfPeriod = 2
            interval = .fivedays
        }
        
        SwiftYFinance.chartDataBy(identifier: symbol, start: Calendar.current.date(byAdding: timePeriod!, value: -numberOfPeriod, to: today)!, end: Date.now, interval: interval!) { data, error in
            if error == nil {
                if let safeData = data {
                    self.delegate?.receivedChartData(for: safeData)
                } else {
                    print("Error: Invalid data")
                }
            } else {
                print(data![0].open ?? "Open price is unavailable")
            }
        }
    }
}





