//
//  Crypto .swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 4.12.22.
//

import Foundation

struct Crypto : Codable {
    let data : [CryptoData]
}

struct CryptoData : Codable {
    let id : Int
    let name : String
    let symbol : String
    let quote : Quote
}

struct Quote : Codable {

    let USD: Rate
    let EUR: Rate
    let GBP: Rate
    let JPY: Rate
    let CAD: Rate
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let USD = try container.decodeIfPresent(Rate.self, forKey: .USD) {
            self.USD = USD
        } else {
            self.USD = Rate(price: 0.0, percent_change_24h: 0.0)
        }
        
        if let EUR = try container.decodeIfPresent(Rate.self, forKey: .EUR) {
            self.EUR = EUR
        } else {
            self.EUR = Rate(price: 0.0, percent_change_24h: 0.0)
        }
        
        if let GBP = try container.decodeIfPresent(Rate.self, forKey: .GBP) {
            self.GBP = GBP
        } else {
            self.GBP = Rate(price: 0.0, percent_change_24h: 0.0)
        }
        
        if let JPY = try container.decodeIfPresent(Rate.self, forKey: .JPY) {
            self.JPY = JPY
        } else {
            self.JPY = Rate(price: 0.0, percent_change_24h: 0.0)
        }
        
        if let CAD = try container.decodeIfPresent(Rate.self, forKey: .CAD) {
            self.CAD = CAD
        } else {
            self.CAD = Rate(price: 0.0, percent_change_24h: 0.0)
        }
    }
   
}

struct Rate : Codable {
    let price : Double
    let percent_change_24h : Double
}
