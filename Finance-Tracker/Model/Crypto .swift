//
//  Crypto .swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 4.12.22.
//

import Foundation

struct Crypto : Codable {
    let data: [CryptoData]
}

struct CryptoData : Codable {
    let id: Int
    let name: String
    let symbol: String
    let circulating_supply: Double
    let total_supply: Double
    let max_supply: Int?
    let cmc_rank: Int
    let quote: Quote
}

struct Quote : Codable {

    let USD: Rate
    let EUR: Rate
    let GBP: Rate
    let JPY: Rate
    let CAD: Rate
    let CHF: Rate
    let KRW: Rate
    let INR: Rate
    let HKD: Rate
    let AUD: Rate
    let TWD: Rate
    let BRL: Rate
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let USD = try container.decodeIfPresent(Rate.self, forKey: .USD) {
            self.USD = USD
        } else {
            self.USD = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let EUR = try container.decodeIfPresent(Rate.self, forKey: .EUR) {
            self.EUR = EUR
        } else {
            self.EUR = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let GBP = try container.decodeIfPresent(Rate.self, forKey: .GBP) {
            self.GBP = GBP
        } else {
            self.GBP = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let JPY = try container.decodeIfPresent(Rate.self, forKey: .JPY) {
            self.JPY = JPY
        } else {
            self.JPY = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let CAD = try container.decodeIfPresent(Rate.self, forKey: .CAD) {
            self.CAD = CAD
        } else {
            self.CAD = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let CHF = try container.decodeIfPresent(Rate.self, forKey: .CHF) {
            self.CHF = CHF
        } else {
            self.CHF = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let KRW = try container.decodeIfPresent(Rate.self, forKey: .KRW) {
            self.KRW = KRW
        } else {
            self.KRW = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let INR = try container.decodeIfPresent(Rate.self, forKey: .INR) {
            self.INR = INR
        } else {
            self.INR = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let HKD = try container.decodeIfPresent(Rate.self, forKey: .HKD) {
            self.HKD = HKD
        } else {
            self.HKD = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let AUD = try container.decodeIfPresent(Rate.self, forKey: .AUD) {
            self.AUD = AUD
        } else {
            self.AUD = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let TWD = try container.decodeIfPresent(Rate.self, forKey: .TWD) {
            self.TWD = TWD
        } else {
            self.TWD = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
        
        if let BRL = try container.decodeIfPresent(Rate.self, forKey: .BRL) {
            self.BRL = BRL
        } else {
            self.BRL = Rate(price: 0.0, percent_change_24h: 0.0, volume_24h: 0.0)
        }
    }
}

struct Rate: Codable {
    let price: Double
    let percent_change_24h: Double
    let volume_24h: Double
}
