//
//  CryptoManager.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 4.12.22.
//

import Foundation

protocol CryptoManagerDelegate {
    func receivedInformation()
}

class CryptoManager {

    var delegate : CryptoManagerDelegate?
    let defaults = UserDefaults.standard
    
    var urlString = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=5&convert="
    var returnArray: [CryptoData] = []
    var cryptoResponse : Crypto? = nil
    
    // Performs single HTTP request to CoinAPI
    func performRequest() {
        returnArray = [] 
        let requestString = urlString + (defaults.string(forKey: K.defaultFiat) ?? "USD")
        if let URL = URL(string: requestString) {
            var request = URLRequest(url: URL)
            request.addValue(Keys.coinMarketCap, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
            request.httpMethod = "GET"
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
                if let safeData = data {
                    let stringData = String(data: safeData, encoding: .utf8)
                    print(stringData!)
                    self.cryptoResponse = self.parseJSON(from: safeData)
                }
                self.parseData()
                DispatchQueue.main.async {
                    self.delegate?.receivedInformation()
                }
            }
            task.resume()
        }
    }
    
    func parseData() {
        for coinData in cryptoResponse!.data {
            returnArray.append(coinData)
        }
    }
    
    // Parses JSON data received from CoinAPI 
    func parseJSON(from data: Data) -> Crypto? {
        let decoder = JSONDecoder()
        do {
            let crypto = try decoder.decode(Crypto.self, from: data)
            return crypto
        } catch {
            print("Error while decoding: \(error)")
        }
        return nil
    }
    
}
