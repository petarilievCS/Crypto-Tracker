//
//  GraphViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 2.12.22.
//

import UIKit
import Charts
import TinyConstraints
import SwiftYFinance

enum Period {
    case day
    case fiveDays
    case month
    case threeMonths
    case sixMonths
    case year
    case twoYears
}

class GraphViewController: UIViewController {
    
    // Chart view
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .clear
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.legend.enabled = false
        return chartView
    }()
    
    var yValue: [ChartDataEntry] = []
    var timePeriod: Period = .day
    
    var selectedCurrency: CryptoData? = nil
    var selectedStock: IndexEntry? = nil
    var volume: Double = 0.0 
    var price: String = ""
    var percentChange: String = ""
    let cryptoManager = CryptoManager()
    let stockManager = StockManager()
    var crypto: [CryptoData] = []
    
    // TODO: Change to computed variable
    var isFavorite: Bool = false
    let defaults = UserDefaults.standard
    var isStocks: Bool = false
    
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
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var fiveDaysButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var sixMonthsButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var threeMonthsButton: UIButton!
    @IBOutlet weak var twoYearsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        cryptoManager.delegate = self
        stockManager.delegate = self
        refreshInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        symbolLabel.text = ""
        nameLabel.text = ""
        priceLabel.text = ""
        percentChangeLabel.text = ""
        
        let favorites = defaults.array(forKey: K.defaultFavorites) as? [String] ?? []
        
        for symbol in favorites {
            if symbol == selectedCurrency!.symbol {
                isFavorite = true
                favoriteButton.image = UIImage(systemName: "heart.fill")
                break
            }
        }
    }
    
    // Sets data in chart view
    func setData() {
        let set1 =  LineChartDataSet(entries: yValue, label: "Price")
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 2
        set1.setColor(percentChangeLabel.textColor)
        set1.fillColor = percentChangeLabel.textColor
        set1.fillAlpha = 0.5
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = false
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }
    
    // Refreshes information
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        cryptoManager.performRequest()
    }
    
    // Add crypto to favorites
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        var favorites = defaults.array(forKey: K.defaultFavorites)
        
        if !isFavorite {
            // Add to favorites
            if favorites != nil {
                favorites!.append(selectedCurrency!.symbol)
                defaults.set(favorites, forKey: K.defaultFavorites)
            } else {
                defaults.set([selectedCurrency!.symbol], forKey: K.defaultFavorites)
            }
        } else {
            for i in 0...(favorites!.count - 1) {
                if favorites![i] as! String == selectedCurrency!.symbol {
                    favorites?.remove(at: i)
                    break
                }
            }
            defaults.set(favorites, forKey: K.defaultFavorites)
        }
        
    
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
        
        return Utilities.formatDecimal(Double(priceString)! * supply, with: "")
    }
    
    // MARK: - Button Actions
    
    @IBAction func dayButtonPressed(_ sender: UIButton) {
        deselectButtons()
        dayButton.backgroundColor = .systemGray5
        timePeriod = .day
        cryptoManager.performCoinAPIRequest(for: selectedCurrency!.symbol, in: defaults.string(forKey: K.defaultFiat) ?? "USD", timePeriod)
    }
    
    @IBAction func fiveDaysButtonPressed(_ sender: UIButton) {
        deselectButtons()
        fiveDaysButton.backgroundColor = .systemGray5
        timePeriod = .fiveDays
        cryptoManager.performCoinAPIRequest(for: selectedCurrency!.symbol, in: defaults.string(forKey: K.defaultFiat) ?? "USD", timePeriod)
    }
    
    @IBAction func monthButtonPressed(_ sender: UIButton) {
        deselectButtons()
        monthButton.backgroundColor = .systemGray5
        timePeriod = .month
        cryptoManager.performCoinAPIRequest(for: selectedCurrency!.symbol, in: defaults.string(forKey: K.defaultFiat) ?? "USD", timePeriod)
    }
    
    @IBAction func sixMonthsButtonPressed(_ sender: UIButton) {
        deselectButtons()
        sixMonthsButton.backgroundColor = .systemGray5
        timePeriod = .sixMonths
        cryptoManager.performCoinAPIRequest(for: selectedCurrency!.symbol, in: defaults.string(forKey: K.defaultFiat) ?? "USD", timePeriod)
    }
    
    @IBAction func yearButtonPressed(_ sender: UIButton) {
        deselectButtons()
        yearButton.backgroundColor = .systemGray5
        timePeriod = .year
        cryptoManager.performCoinAPIRequest(for: selectedCurrency!.symbol, in: defaults.string(forKey: K.defaultFiat) ?? "USD", timePeriod)
    }

    @IBAction func threeMonthsButtonPressed(_ sender: Any) {
        deselectButtons()
        threeMonthsButton.backgroundColor = .systemGray5
        timePeriod = .threeMonths
        cryptoManager.performCoinAPIRequest(for: selectedCurrency!.symbol, in: defaults.string(forKey: K.defaultFiat) ?? "USD", timePeriod)
    }
    
    @IBAction func twoYearsButtonPressed(_ sender: UIButton) {
        deselectButtons()
        twoYearsButton.backgroundColor = .systemGray5
        timePeriod = .twoYears
        cryptoManager.performCoinAPIRequest(for: selectedCurrency!.symbol, in: defaults.string(forKey: K.defaultFiat) ?? "USD", timePeriod)
    }
    
    func deselectButtons() {
        dayButton.backgroundColor = .systemBackground
        fiveDaysButton.backgroundColor = .systemBackground
        monthButton.backgroundColor = .systemBackground
        sixMonthsButton.backgroundColor = .systemBackground
        yearButton.backgroundColor = .systemBackground
        threeMonthsButton.backgroundColor = .systemBackground
        twoYearsButton.backgroundColor = .systemBackground
    }
    
    // MARK: - Refreshing information methods
    
    func refreshInformation() {
        
        if isStocks {
            refreshStockInformation()
        } else {
            // Customize main info
            symbolLabel.text = selectedCurrency?.symbol
            nameLabel.text = selectedCurrency?.name
            priceLabel.text = price
            
            // Customize percent change label
            percentChangeLabel.text = percentChange
            percentChangeLabel.textColor = percentChange.first == "-" ? UIColor(named: "Signature Red") : UIColor(named: "Signature Green")
            
            customizeViews()
            
            // Customize data views
            mktCapPriceLabel.text = calculateMktCap(FD: false)
            fdMktCapPriceLabel.text = calculateMktCap(FD: true)
            rankLabel.text = "#\(String(selectedCurrency!.cmc_rank))"
            circulatingSupplyLabel.text = String(Utilities.formatDecimal(selectedCurrency!.circulating_supply, with: ""))
            totalSupplyLabel.text = Utilities.formatDecimal(selectedCurrency!.total_supply, with: "")
            
            let unformattedVolume = Int(Utilities.getRate(for: selectedCurrency!, in: defaults.string(forKey: K.defaultFiat) ?? "USD").volume_24h)
            volumeLabel.text = Utilities.formatDecimal(Double(unformattedVolume), with: "")
            
            if let maxSupply = selectedCurrency?.max_supply {
                maxSupplyLabel.text = Utilities.formatDecimal(Double(maxSupply), with: "")
            } else {
                maxSupplyLabel.text = "--"
            }
            
            let dominance = Utilities.getRate(for: selectedCurrency!, in: defaults.string(forKey:  K.defaultFiat) ?? "USD").market_cap_dominance
            dominanceLabel.text = String(format: "%.1f", dominance) + "%"
            
            // Setup chart view
            chartView.addSubview(lineChartView)
            lineChartView.centerInSuperview()
            lineChartView.width(to: chartView)
            lineChartView.height(to: chartView)
            cryptoManager.performCoinAPIRequest(for: selectedCurrency!.symbol, in: defaults.string(forKey: K.defaultFiat) ?? "USD", timePeriod)
        }
    }
    
    // Refresh information for stocks
    func refreshStockInformation() {
        if let safeSymbol = selectedStock?.symbol {
            stockManager.getInfo(for: safeSymbol)
        } else {
            print("No selected stock symbol")
        }
    }
    
    func customizeViews() {
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
        dayButton.layer.cornerRadius = K.viewCornerRadius
        dayButton.titleLabel?.font = UIFont(name: "System Semibold", size: 17.0)
        fiveDaysButton.layer.cornerRadius = K.viewCornerRadius
        fiveDaysButton.titleLabel?.font = UIFont(name: "System Semibold", size: 17.0)
        monthButton.layer.cornerRadius = K.viewCornerRadius
        monthButton.titleLabel?.font = UIFont(name: "System Semibold", size: 17.0)
        sixMonthsButton.layer.cornerRadius = K.viewCornerRadius
        sixMonthsButton.titleLabel?.font = UIFont(name: "System Semibold", size: 17.0)
        yearButton.layer.cornerRadius = K.viewCornerRadius
        yearButton.titleLabel?.font = UIFont(name: "System Semibold", size: 17.0)
        threeMonthsButton.layer.cornerRadius = K.viewCornerRadius
        threeMonthsButton.titleLabel?.font = UIFont(name: "System Semibold", size: 17.0)
        twoYearsButton.layer.cornerRadius = K.viewCornerRadius
        twoYearsButton.titleLabel?.font = UIFont(name: "System Semibold", size: 17.0)
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
        crypto = cryptoManager.returnArray
        
        // Find selected currency
        let selectedCurrencySymbol = selectedCurrency!.symbol
        let currentFiat = defaults.string(forKey: K.defaultFiat) ?? "USD"
        let currentRate = Utilities.getRate(for: selectedCurrency!, in: currentFiat)
        for cryptoCurrency in crypto {
            if cryptoCurrency.symbol == selectedCurrencySymbol {
                self.selectedCurrency = cryptoCurrency
                self.price = Utilities.formatPriceLabel(String(format: "%.2f", currentRate.price), with: Utilities.getSymbol(for: currentFiat))
                self.percentChange = String(format: "%.2f", currentRate.percent_change_24h) + "%"
                break
            }
        }
        refreshInformation()
    }
}


// MARK: - Stock Manager Delegate methds

extension GraphViewController: StockManagerDelegate {
    
    func receivedStockInformation() {}
    
    // Updates view when information is received
    func receivedSymbolInformatioN(for symbol: RecentStockData) {
        // Customize main info
        symbolLabel.text = symbol.symbol
        nameLabel.text = selectedStock?.name ?? symbol.symbol
        priceLabel.text = "$\(symbol.regularMarketPrice ?? 0.0)"
        
        // TODO: Calculate percent change
        
        customizeViews()
        
    }
    
}
