//
//  GraphViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 2.12.22.
//

import UIKit

class GraphViewController: UIViewController {
    
    var selectedCurrency: CryptoData? = nil
    var price: String = ""
    var percentChange: String = ""
    
    // TODO: Change to computed variable
    var isFavorite: Bool = false
    
    // Outlets
    @IBOutlet weak var mktCapView: UIView!
    @IBOutlet weak var fdMktCapView: UIView!
    @IBOutlet weak var openView: UIView!
    @IBOutlet weak var closedView: UIView!
    @IBOutlet weak var marketCapView: UIView!
    @IBOutlet weak var graphView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var percentChangeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    @IBOutlet weak var mktCapLabel: UILabel!
    @IBOutlet weak var mktCapPriceLabel: UILabel!
    @IBOutlet weak var fdMktCapPriceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize main info
        symbolLabel.text = selectedCurrency?.symbol
        nameLabel.text = selectedCurrency?.name
        priceLabel.text = price
        
        // Customize percent change label
        percentChangeLabel.text = percentChange
        percentChangeLabel.textColor = percentChange.first == "-" ? UIColor(named: "Signature Red") : UIColor(named: "Signature Green")
        
        // Customize view
        mktCapView.layer.cornerRadius = K.viewCornerRadius
        fdMktCapView.layer.cornerRadius = K.viewCornerRadius
        openView.layer.cornerRadius = K.viewCornerRadius
        closedView.layer.cornerRadius = K.viewCornerRadius
        mktCapView.layer.cornerRadius = K.viewCornerRadius
        graphView.layer.cornerRadius = K.viewCornerRadius
        
        // Customize data views
        mktCapPriceLabel.text = calculateMktCap(FD: false)
        fdMktCapPriceLabel.text = calculateMktCap(FD: true)
    }
    
    // Add crypto to favorites 
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        favoriteButton.image = isFavorite ? UIImage(systemName: "heart") : UIImage(systemName: "heart.fill")
        isFavorite = !isFavorite
    }
    
    // Returns the market cap of the current crypto
    func calculateMktCap(FD: Bool) -> String {
        
        var supply = 0.0
        
        if !FD {
            supply = selectedCurrency!.circulating_supply
        } else {
            if let maxSupply = selectedCurrency!.max_supply {
                supply = Double(maxSupply)
            } else {
                supply = selectedCurrency!.total_supply
            }
        }
        
        var priceString = priceLabel.text!
        var fiatCurrency = String(priceString.removeFirst())
    
        // Brasilian Reals
        if priceString.first! == "$" {
            fiatCurrency += String(priceString.removeFirst())
        }
        
        priceString.removeAll { char in
            return char == ","
        }
        
        return Utilities.format(Int(Double(priceString)! * supply), with: fiatCurrency)
    }
}
 
