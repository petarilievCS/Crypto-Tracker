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
    var coinAPIString = "https://rest.coinapi.io/v1/exchangerate/BTC/USD/history?period_id=1DAY&time_start=2022-11-01T00:00:00&time_end=2022-11-08T00:00:00"
    var returnArray: [CryptoData] = []
    var cryptoResponse: Crypto? = nil
    var cryptoHistory: [CryptoQuote]? = []
    
    // Performs single HTTP request to CoinAPI
    func performCoinAPIRequest() {
        let URLString = coinAPIString
        if let URL = URL(string: URLString) {
            var request = URLRequest(url: URL)
            request.setValue(Keys.coinAPI, forHTTPHeaderField: "X-CoinAPI-Key")
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
                if let safeData = data {
                    let stringData = String(data: safeData, encoding: .utf8)
                    print(stringData!)
                    self.cryptoHistory = self.parseHistoryJSON(from: safeData)
                }
                DispatchQueue.main.async {
                    self.delegate?.receivedInformation()
                }
            }
            task.resume()
        }
        
    }
    
    // Performs single HTTP request to CoinMarketCap API
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
    
    // Parse JSON for crypto history form CoinAPI
    func parseHistoryJSON(from data: Data) -> [CryptoQuote]? {
        let decoder = JSONDecoder()
        do {
            let history = try decoder.decode([CryptoQuote].self, from: data)
            return history
        } catch {
            print("Error while decoding: \(error)")
        }
        return nil
    }
    
    // Parses JSON data received from CoinMarketCap API
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
