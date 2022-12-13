//
//  GraphViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 2.12.22.
//

import UIKit
import Charts
import TinyConstraints

class GraphViewController: UIViewController {
    
    // Chart view
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemGray6
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        return chartView
    }()
    
    var yValue: [ChartDataEntry] = [
        ChartDataEntry(x: 0.0, y: 5.0),
        ChartDataEntry(x: 1.0, y: 10.0),
        ChartDataEntry(x: 2.0, y: 12.0),
        ChartDataEntry(x: 3.0, y: 15.0),
        ChartDataEntry(x: 4.0, y: 9.0),
        ChartDataEntry(x: 5.0, y: 7.0),
        ChartDataEntry(x: 6.0, y: 10.0),
        ChartDataEntry(x: 7.0, y: 5.0),
        ChartDataEntry(x: 8.0, y: 4.0),
        ChartDataEntry(x: 9.0, y: 0.0),
        ChartDataEntry(x: 10.0, y: 5.0)
    ]
    
    var selectedCurrency: CryptoData? = nil
    var volume: Double = 0.0 
    var price: String = ""
    var percentChange: String = ""
    let cryptoManager = CryptoManager()
    
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
        cryptoManager.delegate = self
        
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
        lineChartView.width(to: chartView)
        lineChartView.height(to: chartView)
        setData()
                
    }
    
    // Sets data in chart view
    func setData() {
        let set1 =  LineChartDataSet(entries: yValue, label: "Price")
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 2
        set1.setColor(UIColor(named: "Signature Green")!)
        set1.fillColor = UIColor(named: "Signature Green")!
        set1.fillAlpha = 0.5
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = false
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }
    
    // Add crypto to favorites 
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        cryptoManager.performCoinAPIRequest()
        
        
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
 
// MARK: - Chart View Delegate methods

extension GraphViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
}

// MARK: - Crypto Manager Delegate methods

extension GraphViewController: CryptoManagerDelegate {
    func receivedInformation() {
        if let history = cryptoManager.cryptoHistory {
            yValue = []
            var counter = 0.0
            for quote in history {
                yValue.append(ChartDataEntry(x: counter, y: quote.rate_open))
                counter += 1.0
            }
            setData()
        }
    }
}
