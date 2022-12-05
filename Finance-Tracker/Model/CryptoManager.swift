//
//  CryptoManager.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 4.12.22.
//

import Foundation

class CryptoManager {
    
    let cryptoCurrencies = ["BTC", "ETH", "USDT", "BNB", "USDC", "BUSD", "XRP", "DOGE", "ADA", "MATIC"]
    let urlString = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/info?symbol=BTC,ETH,ADA"
    var returnArray: [CryptoData] = []
    var cryptoResponse : Crypto? = nil
    
    let dispatchQueue = DispatchQueue(label: "cryptoQueue") // serial queue
    let semaphore = DispatchSemaphore(value: 1)
    
    // Performs HTTP requests to CoinAPI for top 10 crypto currencies
    func performRequests() {
//        for currency in cryptoCurrencies {
//            dispatchQueue.async {
//                self.semaphore.wait()
//                self.performRequest(with: currency)
//            }
//        }
        performRequest(with: "Random Test")
    }
    
    // Performs single HTTP request to CoinAPI
    func performRequest(with cryptoCurrency: String) {
        if let URL = URL(string: urlString) {
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
                self.semaphore.signal()
            }
            task.resume()
        }
    }
    
    func parseData() {
        for (coin, coinData) in cryptoResponse!.data {
            returnArray.append(coinData[0])
        }
        //returnArray.append(cryptoResponse!.data["BTC"]![0])
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
