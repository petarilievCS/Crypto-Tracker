//
//  GraphViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 2.12.22.
//

import UIKit
import Charts

class GraphViewController: UIViewController {
    
    // View used for graph
    lazy var lineChartView: LineChartView = {
        let chartV = LineChartView()
        chartV.backgroundColor = .systemGray2
        return chartV
    }()
    
    var selectedCurrency: CryptoData? = nil
    var volume: Double = 0.0 
    var price: String = ""
    var percentChange: String = ""
    
    // TODO: Change to computed variable
    var isFavorite: Bool = false
    let defaults = UserDefaults.standard
    
    // Outlets
    @IBOutlet weak var mktCapView: UIView!
    @IBOutlet weak var fdMktCapView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var percentChangeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var circulatingSupplyView: UIView!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var mktCapLabel: UILabel!
    @IBOutlet weak var mktCapPriceLabel: UILabel!
    @IBOutlet weak var fdMktCapPriceLabel: UILabel!
    @IBOutlet weak var circulatingSupplyLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var maxSupplyView: UIView!
    @IBOutlet weak var maxSupplyLabel: UILabel!
    @IBOutlet weak var totalSupplyView: UILabel!
    @IBOutlet weak var totalSupplyLabel: UILabel!
    @IBOutlet weak var rankView: UIView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var dominanceLabel: UILabel!
    @IBOutlet weak var dominanceView: UIView!
    @IBOutlet weak var chartView: UIView!
    
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
        mktCapView.layer.cornerRadius = K.viewCornerRadius
        volumeView.layer.cornerRadius = K.viewCornerRadius
        circulatingSupplyView.layer.cornerRadius = K.viewCornerRadius
        maxSupplyView.layer.cornerRadius = K.viewCornerRadius
        totalSupplyView.layer.cornerRadius = K.viewCornerRadius
        rankView.layer.cornerRadius = K.viewCornerRadius
        dominanceView.layer.cornerRadius = K.viewCornerRadius
        
        // Customize data views
        mktCapPriceLabel.text = calculateMktCap(FD: false)
        fdMktCapPriceLabel.text = calculateMktCap(FD: true)
        rankLabel.text = "#\(String(selectedCurrency!.cmc_rank))"
        circulatingSupplyLabel.text = String(Utilities.format(Int(selectedCurrency!.circulating_supply), with: "")) + " \(selectedCurrency!.symbol)"
        totalSupplyLabel.text = Utilities.format(Int(selectedCurrency!.total_supply), with: "") + " \(selectedCurrency!.symbol)"
        
        let unformattedVolume = Int(Utilities.getRate(for: selectedCurrency!, in: defaults.string(forKey: K.defaultFiat)!).volume_24h)
        volumeLabel.text = Utilities.format(unformattedVolume, with: Utilities.getSymbol(for: defaults.string(forKey: K.defaultFiat)!))
        
        if let maxSupply = selectedCurrency?.max_supply {
            maxSupplyLabel.text = Utilities.format(maxSupply, with: "") + " \(selectedCurrency!.symbol)"
        } else {
            maxSupplyLabel.text = "--"
        }
        
        let dominance = Utilities.getRate(for: selectedCurrency!, in: defaults.string(forKey:  K.defaultFiat)!).market_cap_dominance
        dominanceLabel.text = String(format: "%.1f", dominance) + "%"
        
        chartView.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.frame.size.width = chartView.frame.size.width
        lineChartView.frame.size.height = chartView.frame.size.height
        
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
 
// MARK: - UI View methods

extension UIView {
    
    func centerInSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerHorizontallyInSuperview()
        self.centerVerticallyInSuperview()
    }
    
    func centerHorizontallyInSuperview(){
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: self.superview, attribute: .centerX, multiplier: 1, constant: 0)
        self.superview?.addConstraint(c)
    }
    
    func centerVerticallyInSuperview(){
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: self.superview, attribute: .centerY, multiplier: 1, constant: 0)
        self.superview?.addConstraint(c)
    }
    
}
