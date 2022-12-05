//
//  Crypto .swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 4.12.22.
//

import Foundation

struct Crypto : Codable {
    let data : [String : [CryptoData]]
}

struct CryptoData : Codable {
    let name : String
    let symbol : String
}
