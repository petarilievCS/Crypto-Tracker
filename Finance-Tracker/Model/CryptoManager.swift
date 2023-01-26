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
    
    let dateFormatter = DateFormatter()
    var delegate : CryptoManagerDelegate?
    let defaults = UserDefaults.standard
    
    var urlString = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=200&convert="
    var returnArray: [CryptoData] = []
    var cryptoResponse: Crypto? = nil
    var cryptoHistory: [CryptoQuote]? = []
    
    // Performs single HTTP request to CoinAPI
    func performCoinAPIRequest(for cryptoCurrency: String, in fiatCurrency: String, _ timePeriod: Period) {
        
        let today = getToday().replacingOccurrences(of: "+0000", with: "")
        let start = getStart(for: timePeriod).replacingOccurrences(of: "+0000", with: "")
        let URLString = createCoinAPIURL(for: cryptoCurrency, in: fiatCurrency, from: start, to: today, timePeriod)
        
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
    
    // Creates URL for CoinAPI with given parameters
    func createCoinAPIURL(for cryptoCurrency: String, in fiatCurrency: String, from start: String, to end: String, _ timePeriod: Period) -> String {
        
        var frequency = ""
        switch timePeriod {
        case .day:
            frequency = "15MIN"
        case .fiveDays:
            frequency = "1HRS"
        case .month:
            frequency = "8HRS"
        case .threeMonths:
            frequency = "1DAY"
        case .sixMonths:
            frequency = "2DAY"
        case .year:
            frequency = "3DAY"
        case .twoYears:
            frequency = "7DAY"
        }
        
        return  "https://rest.coinapi.io/v1/exchangerate/\(cryptoCurrency)/\(fiatCurrency)/history?period_id=\(frequency)&time_start=\(start)&time_end=\(end)"
    }
    
    // Gets starting date depending on time period
    func getStart(for timePeriod: Period) -> String {
        setupFormatter()
        let currentDate = Date()
        let calendar = Calendar.current
        var startDate = Date()
        
        switch timePeriod {
        case .day:
            startDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        case .fiveDays:
            startDate = calendar.date(byAdding: .day, value: -5, to: currentDate)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: currentDate)!
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: currentDate)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: currentDate)!
        case .twoYears:
            startDate = calendar.date(byAdding: .year, value: -2, to: currentDate)!
        }
        return dateFormatter.string(from: startDate)
    }
    
    // Gets current date in ISO format
    func getToday() -> String {
        setupFormatter()
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }
    
    // Sets up date formatter
    func setupFormatter() {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
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
        if let safeResponse = cryptoResponse {
            for coinData in safeResponse.data {
                returnArray.append(coinData)
            }
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
