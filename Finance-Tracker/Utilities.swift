//
//  Utilities.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 4.12.22.
//

import UIKit

class Utilities {
    
    // Creates a basic shake animation for the text fields
    static func shake(_ viewToShake: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x - 10, y: viewToShake.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x + 10, y: viewToShake.center.y))
        viewToShake.layer.add(animation, forKey: "position")
    }
    
    // Checks if a string is a valid email
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Formats a double as a decimal
    static func format(_ number: Int, with currency: String) -> String {
        
        // Format price
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return currency + numberFormatter.string(from: NSNumber(value: number))!
    }
    
    // Gets the rate in the current selected currency
    static func getRate(for crypto: CryptoData, in fiat: String) -> Rate {
        switch fiat {
        case "AUD":
            return crypto.quote.AUD
        case "BRL":
            return crypto.quote.BRL
        case "CAD":
            return crypto.quote.CAD
        case "CHF":
            return crypto.quote.CHF
        case "EUR":
            return crypto.quote.EUR
        case "GBP":
            return crypto.quote.GBP
        case "HKD":
            return crypto.quote.HKD
        case "INR":
            return crypto.quote.INR
        case "JPY":
            return crypto.quote.JPY
        case "KRW":
            return crypto.quote.KRW
        case "TWD":
            return crypto.quote.TWD
        default:
            return crypto.quote.USD 
        }
    }
    
    // Returns symbol for given fiat currency
    static func getSymbol(for currency: String) -> String {
        switch currency {
        case "BRL":
            return "R$"
        case "CHF":
            return "₣"
        case "EUR":
            return "€"
        case "GBP":
            return "£"
        case "JPY":
            return "¥"
        case "KRW":
            return "₩"
        case "INR":
            return "₹"
        default:
            return "$"
        }
    }
    
}
