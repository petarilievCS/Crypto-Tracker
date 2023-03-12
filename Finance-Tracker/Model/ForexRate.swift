//
//  ForexRate.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 11.3.23.
//

import Foundation

class ForexRate: Codable {
    var shortsymbol: String
    var last: String
    var name: String
    
    init(shortsymbol: String, last: String, name: String) {
        self.shortsymbol = shortsymbol
        self.last = last
        self.name = name
    }
}
