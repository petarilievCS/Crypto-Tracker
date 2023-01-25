//
//  stockManager.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 24.1.23.
//

import Foundation

protocol StockManagerDelegate {
    func receivedStockInformation()
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
}





