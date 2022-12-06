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
    let USD : Rate
}

struct Rate : Codable {
    let price : Double
    let percent_change_24h : Double
}
