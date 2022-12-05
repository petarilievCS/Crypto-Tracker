//
//  CryptoManager.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 4.12.22.
//

import Foundation

class CryptoManager {
    
    let cryptoCurrencies = ["BTC", "ETH", "USDT", "BNB", "USDC", "BUSD", "XRP", "DOGE", "ADA", "MATIC"]
    let urlString = "https://rest.coinapi.io/v1/exchangerate"
    var returnArray: [Crypto] = []
    
    // Performs HTTP requests to CoinAPI for top 10 crypto currencies
    func performRequests() {
        for currency in cryptoCurrencies {
            performRequest(with: currency)
        }
    }
    
    // Performs single HTTP request to CoinAPI
    func performRequest(with cryptoCurrency: String) {
        let requestString = urlString + "/\(cryptoCurrency)/USD?apikey=\(Keys.coinAPI)"
        if let URL = URL(string: requestString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: URL) { data, response, error in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
                if let safeData = data {
                    if let returnValue =  self.parseJSON(from: safeData) {
                        self.returnArray.append(returnValue)
                    }
                }
            }
            task.resume()
        }
    }
    
    // Parses JSON data received from CoinAPI 
    func parseJSON(from data: Data) -> Crypto? {
        let decoder = JSONDecoder()
        do {
            let crypto = try decoder.decode(Crypto.self, from: data)
            return crypto
        } catch {
            print("Error while decoding: \(error.localizedDescription)")
        }
        return nil
    }
    
}
