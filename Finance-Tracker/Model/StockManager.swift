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
}

class StockManager {
    
    var indexFundEntries: [IndexEntry] = []
    var delegate: StockManagerDelegate?
    
    // Performs API request in order to obtain list of NASDAQ companies
    func performRequest() {
        let url = URL(string: "https://financialmodelingprep.com/api/v3/nasdaq_constituent?apikey=8a4725e21f6e6631195ac4cd66b7e201")
        var request = URLRequest(url: url!)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            self.parseJSON(from: data)
        }
        task.resume()
    }
    
    // Parses JSON response into array of index entries
    func parseJSON(from data: Data) {
        let decoder = JSONDecoder()
        do {
            indexFundEntries = try decoder.decode([IndexEntry].self, from: data)
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
                    self.delegate?.receivedSymbolMetrics(for: safeData[1])
                } else {
                    print("Error: Invalid data")
                }
            } else {
                print(data![0].open ?? "Open price is unavailable")
            }
        }
    }
}





