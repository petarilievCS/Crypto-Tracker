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
    
    // Return double in short format
    static func formatDecimal(_ number: Double, with currency: String) -> String {
        
        switch number {
        case ...999999.0:
            // no formatting
            return Utilities.format(Int(number), with: currency)
        case 1000000..<1000000000:
            // format with M
            print(number)
            let millions = number / 1000000
            let roundedDouble = Double(Int(millions * 100)) / 100
            print("\(currency)\(roundedDouble)M")
            return "\(currency)\(roundedDouble) M"
        case 1000000000..<1000000000000:
            // format with B
            print(number)
            let billions = number / 1000000000
            let roundedDouble = Double(Int(billions * 100)) / 100
            print("\(currency)\(roundedDouble)B")
            return "\(currency)\(roundedDouble) B"
        default:
            // format with T
            print(number)
            let trillions = number / 1000000000000
            let roundedDouble = Double(Int(trillions * 100)) / 100
            print("\(currency)\(roundedDouble)T")
            return "\(currency)\(roundedDouble) T"
        }
        
    }
    
    // Formats price label
    static func formatPriceLabel(_ stringPrice: String, with fiatSymbol: String) -> String {
        // Format price
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let doublePrice = Double(stringPrice)!
        return fiatSymbol + numberFormatter.string(from: NSNumber(value: doublePrice))!
    }
    
}
