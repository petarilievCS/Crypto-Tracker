//
//  ForexManager.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 11.3.23.
//

import Foundation

protocol ForexManagerDelegate {
    func didReceiveForexData(with data: [ForexRate])
}

struct ForexManager {
    
    let foreignCurrencies: [String] = ["AED", "AFN", "ALL", "AMD", "ANG", "AOA", "ARS", "AUD", "AWG", "BAM", "BBD", "BDT", "BGN", "BHD", "BIF", "BMD", "BND", "BOB", "BRL", "BSD", "BTN", "BWP", "BZD", "CAD", "CDF", "CHF", "CLP", "CNY", "COP", "CRC", "CUP", "CVE", "CZK", "DJF", "DKK", "DOP", "DZD", "EGP", "ETB", "EUR", "FJD", "GBP", "GEL", "GHS", "GMD", "GNF", "GTQ", "HKD", "HNL", "HTG", "HUF", "IDR", "ILS", "INR", "IQD", "IRR", "ISK", "JMD", "JOD", "JPY", "KES", "KGS", "KHR", "KMF", "KRW", "KWD", "KYD", "KZT", "LAK", "LBp", "LKR", "LRD", "LSL", "LYD", "MAD", "MDL", "MGA", "MKD", "MMK", "MOP", "MUR", "MVR", "MWK", "MXN", "MYR", "NAD", "NGN", "NIO", "NOK", "NPR", "NZD", "OMR", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN", "PYG", "QAR", "RON", "RSD", "RUB", "SAR", "SBD", "SCR", "SDG", "SEK", "SGD", "SLL", "SOS", "SRD", "THB", "TJS", "TMT", "TND", "TOP", "TRY", "TTD", "TWD", "TZS", "UAH", "UGX", "UYU", "UZS", "VND", "XAF", "XCD", "XOF", "XPF", "YER", "ZAR", "ZMW"]
    let baseURL: String = "https://assets.ino.com/data/quote/?format=json"
    var delegate: ForexManagerDelegate?
    
    // Performs API request for all foreign exchange currencies
    func performRequest() {
        var URLString: String = baseURL
        for currency in foreignCurrencies {
            URLString += "&s=FOREX_USD\(currency)"
        }
        let URL: URL = URL(string: URLString)!
        let session: URLSession = URLSession(configuration: .default)
        let task: URLSessionDataTask = session.dataTask(with: URLRequest(url: URL)) { data, response, error in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
            if let safeData = data {
                let formattedData: Data = formatJSON(safeData)
                parseJSON(formattedData)
            }
        }
        task.resume()
    }
    
    // Edits given JSON
    func formatJSON(_ data: Data) -> Data {
        var dataString: String = String(data: data, encoding: .utf8)!
        var stringArray: [Character] = Array(dataString)
        stringArray[0] = "["
        stringArray[stringArray.count - 2] = "]"
        dataString = String(stringArray)
        dataString = dataString.replacingOccurrences(of: "FOREX_USD", with: "")
        
        let lines = dataString.split(whereSeparator: \.isNewline)
        dataString = ""
        for i in 0..<lines.count {
            if lines[i].count > 3 && lines[i][lines[i].index(lines[i].startIndex, offsetBy: 3)] == "\"" {
                dataString += "   {"
            } else {
                dataString += String(lines[i])
            }
            dataString += "\n"
        }
        return Data(dataString.utf8)
    }
    
    // Parases JSON response
    func parseJSON(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            let forexRates: [ForexRate] = try decoder.decode([ForexRate].self, from: data)
            delegate?.didReceiveForexData(with: forexRates)
        } catch {
            print("Error: \(error)")
        }
    }
}
