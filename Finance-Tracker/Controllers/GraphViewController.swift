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
    
    // Outlets
    @IBOutlet weak var highView: UIView!
    @IBOutlet weak var lowView: UIView!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var openView: UIView!
    @IBOutlet weak var closedView: UIView!
    @IBOutlet weak var marketCapView: UIView!
    @IBOutlet weak var graphView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var percentChangeLabel: UILabel!
    
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
        highView.layer.cornerRadius = K.viewCornerRadius
        lowView.layer.cornerRadius = K.viewCornerRadius
        volumeView.layer.cornerRadius = K.viewCornerRadius
        openView.layer.cornerRadius = K.viewCornerRadius
        closedView.layer.cornerRadius = K.viewCornerRadius
        marketCapView.layer.cornerRadius = K.viewCornerRadius
        graphView.layer.cornerRadius = K.viewCornerRadius
    }
    
}
 
