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
    func receivedChartData(for data: ChartDataModel)
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
    
    func performRequest(for symbol: String) {
        var urlString = "https://query1.finance.yahoo.com/v7/finance/quote?symbols=\(symbol)"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
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
    
    // Perform API request for company prices
    func performPricesRequest() {
        var urlString = "https://query1.finance.yahoo.com/v7/finance/quote?symbols="
        for indexFundEntry in indexFundEntries {
            urlString += indexFundEntry.Symbol + ","
        }
        urlString.removeLast()
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
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
    
    // Calculates percent change of given stock
    func getPercentChange(for stock: RecentStockData) -> Float {
        if let previousClose = stock.previousClose, let currentPrice = stock.regularMarketPrice {
            let difference = currentPrice - previousClose
            let percentChange = previousClose / (difference * 100.0)
            return percentChange
        }
        return 0.0
    }
    
    
    // Get chart data for given stock
    func performChartDataRequest(for symbol: String, in period: Period) {
        var range: String = ""
        var interval: String = ""
        
        switch period {
        case .day:
            range = "1d"
            interval = "5m"
        case .fiveDays:
            range = "5d"
            interval = "5m"
        case .month:
            range = "1mo"
            interval = "1h"
        case .threeMonths:
            range = "3mo"
            interval = "1d"
        case .sixMonths:
            range = "6mo"
            interval = "1d"
        case .year:
            range = "1y"
            interval = "1d"
        case .twoYears:
            range = "2y"
            interval = "5d"
        }
        
        let urlString = "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol)?range=\(range)&interval=\(interval)&includeTimestamp=true&indicators=quote"
        print(urlString)
        let URL = URL(string: urlString)!
        let request = URLRequest(url: URL)
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error while performing request: \(error!)")
            }
            if let safeData = data {
                self.parceChartJSON(from: safeData)
            }
        }
        task.resume()
    }
    
    func parceChartJSON(from data: Data) {
        let decoder = JSONDecoder()
        do {
            let chartData: ChartDataModel = try decoder.decode(ChartDataModel.self, from: data)
            delegate?.receivedChartData(for: chartData)
        } catch {
            print("Error while decoding index entries: \(error)")
        }
    }
    
}





