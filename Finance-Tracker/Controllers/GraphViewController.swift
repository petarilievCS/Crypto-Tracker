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
    var selectedStock: IndexFullEntry? = nil
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
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var percentChangeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var boxLabel1: UILabel!
    @IBOutlet weak var boxValue1: UILabel!
    @IBOutlet weak var boxValue2: UILabel!
    @IBOutlet weak var boxValue4: UILabel!
    @IBOutlet weak var boxLabel3: UILabel!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var boxValue5: UILabel!
    @IBOutlet weak var view6: UILabel!
    @IBOutlet weak var boxValue6: UILabel!
    @IBOutlet weak var view7: UIView!
    @IBOutlet weak var boxValue7: UILabel!
    @IBOutlet weak var boxValue8: UILabel!
    @IBOutlet weak var view8: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var fiveDaysButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var sixMonthsButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var threeMonthsButton: UIButton!
    @IBOutlet weak var twoYearsButton: UIButton!
    @IBOutlet weak var boxLabel2: UILabel!
    @IBOutlet weak var boxLabel4: UILabel!
    @IBOutlet weak var boxLabel5: UILabel!
    @IBOutlet weak var boxLabel6: UILabel!
    @IBOutlet weak var boxValue3: UILabel!
    @IBOutlet weak var boxLabel7: UILabel!
    @IBOutlet weak var boxLabel8: UILabel!
    @IBOutlet weak var view9: UIView!
    @IBOutlet weak var view10: UIView!
    @IBOutlet weak var boxValue9: UILabel!
    @IBOutlet weak var boxValue10: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.largeTitleDisplayMode = .never
        cryptoManager.delegate = self
        stockManager.delegate = self
        nameLabel.adjustsFontSizeToFitWidth = true
        percentChangeLabel.adjustsFontSizeToFitWidth = true
        self.lineChartView.xAxis.drawLabelsEnabled = false
        
        // Setup markers on chart
        let marker:BalloonMarker = BalloonMarker(color: .systemGray5, font: .systemFont(ofSize: 17.0, weight: .medium), textColor: .label, insets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 20.0, right: 10.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)
        marker.isStocks = isStocks
        lineChartView.marker = marker
        
        refreshInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if isStocks {
            symbolLabel.text = "Loading... "
            nameLabel.text = ""
            priceLabel.text = ""
            percentChangeLabel.text = ""
        }
        
        customizeViews()
        
        if isStocks {
            boxLabel3.text = "Dividend Yield"
            boxLabel1.text = "Market Cap"
            boxLabel2.text = "Close"
            boxLabel5.text = "Low"
            boxLabel6.text = "High"
            boxLabel4.text = "Average Volume"
            boxLabel7.text = "Open"
            boxLabel8.text = "Volume"
        } else {
            view9.isHidden = true
            view10.isHidden = true
        }
        
        let favoriteCrypto = defaults.array(forKey: K.defaultCrypto) as? [String] ?? []
        let favoriteStocks = defaults.array(forKey: K.defaultStocks) as? [String] ?? []
        
        if !isStocks {
            for symbol in favoriteCrypto {
                if symbol == selectedCurrency!.symbol {
                    isFavorite = true
                    favoriteButton.image = UIImage(systemName: "heart.fill")
                    break
                }
            }
        } else {
            for symbol in favoriteStocks {
                if symbol == selectedStock!.symbol {
                    isFavorite = true
                    favoriteButton.image = UIImage(systemName: "heart.fill")
                    break
                }
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
        if isStocks {
            stockManager.performRequest(for: selectedStock!.symbol)
            
        } else {
            cryptoManager.performRequest()
        }
    }
    
    // Add crypto to favorites
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        
        
        if !isStocks {
            var favoriteCrypto = defaults.array(forKey: K.defaultCrypto)
            
            if !isFavorite {
                // Add to favorites
                if favoriteCrypto != nil {
                    if isStocks {
                        favoriteCrypto!.append(selectedStock!.symbol)
                    } else {
                        favoriteCrypto!.append(selectedCurrency!.symbol)
                    }
                    defaults.set(favoriteCrypto, forKey: K.defaultCrypto)
                } else {
                    if isStocks {
                        defaults.set([selectedStock!.symbol], forKey: K.defaultCrypto)
                    } else {
                        defaults.set([selectedCurrency!.symbol], forKey: K.defaultCrypto)
                    }
                }
            } else {
                for i in 0...(favoriteCrypto!.count - 1) {
                    if isStocks {
                        if favoriteCrypto![i] as! String == selectedStock!.symbol {
                            favoriteCrypto?.remove(at: i)
                            break
                        }
                    } else {
                        if favoriteCrypto![i] as! String == selectedCurrency!.symbol {
                            favoriteCrypto?.remove(at: i)
                            break
                        }
                    }
                }
                defaults.set(favoriteCrypto, forKey: K.defaultCrypto)
            }
            
        } else {
            
            var favoriteStocks = defaults.array(forKey: K.defaultStocks)
            
            if !isFavorite {
                // Add to favorites
                if favoriteStocks != nil {
                    if isStocks {
                        favoriteStocks!.append(selectedStock!.symbol)
                    } else {
                        favoriteStocks!.append(selectedCurrency!.symbol)
                    }
                    defaults.set(favoriteStocks, forKey: K.defaultStocks)
                } else {
                    if isStocks {
                        defaults.set([selectedStock!.symbol], forKey: K.defaultStocks)
                    } else {
                        defaults.set([selectedCurrency!.symbol], forKey: K.defaultStocks)
                    }
                }
            } else {
                for i in 0...(favoriteStocks!.count - 1) {
                    if isStocks {
                        if favoriteStocks![i] as! String == selectedStock!.symbol {
                            favoriteStocks?.remove(at: i)
                            break
                        }
                    } else {
                        if favoriteStocks![i] as! String == selectedCurrency!.symbol {
                            favoriteStocks?.remove(at: i)
                            break
                        }
                    }
                }
                defaults.set(favoriteStocks, forKey: K.defaultStocks)
            }
            
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
    
    func changePeriod() {
        if isStocks {
            self.stockManager.performChartDataRequest(for: self.selectedStock!.symbol, in: self.timePeriod)
        } else {
            cryptoManager.performCoinAPIRequest(for: selectedCurrency!.symbol, in: defaults.string(forKey: K.defaultFiat) ?? "USD", timePeriod)
        }
    }
    
    @IBAction func dayButtonPressed(_ sender: UIButton) {
        deselectButtons()
        dayButton.backgroundColor = .systemGray5
        timePeriod = .day
        changePeriod()
    }
    
    @IBAction func fiveDaysButtonPressed(_ sender: UIButton) {
        deselectButtons()
        fiveDaysButton.backgroundColor = .systemGray5
        timePeriod = .fiveDays
        changePeriod()
    }
    
    @IBAction func monthButtonPressed(_ sender: UIButton) {
        deselectButtons()
        monthButton.backgroundColor = .systemGray5
        timePeriod = .month
        changePeriod()
    }
    
    @IBAction func sixMonthsButtonPressed(_ sender: UIButton) {
        deselectButtons()
        sixMonthsButton.backgroundColor = .systemGray5
        timePeriod = .sixMonths
        changePeriod()
    }
    
    @IBAction func yearButtonPressed(_ sender: UIButton) {
        deselectButtons()
        yearButton.backgroundColor = .systemGray5
        timePeriod = .year
        changePeriod()
    }
    
    @IBAction func threeMonthsButtonPressed(_ sender: Any) {
        deselectButtons()
        threeMonthsButton.backgroundColor = .systemGray5
        timePeriod = .threeMonths
        changePeriod()
    }
    
    @IBAction func twoYearsButtonPressed(_ sender: UIButton) {
        deselectButtons()
        twoYearsButton.backgroundColor = .systemGray5
        timePeriod = .twoYears
        changePeriod()
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
    
    // MARK: - Refreshing information r
    
    func refreshInformation()  {
        
        if isStocks {
            DispatchQueue.global(priority: .background).async {
                self.refreshStockInformation()
            }
        } else {
            // Customize main info
            symbolLabel.text = selectedCurrency?.symbol
            nameLabel.text = selectedCurrency?.name
            priceLabel.text = price
            
            // Customize percent change label
            percentChangeLabel.text = percentChange
            percentChangeLabel.textColor = percentChange.first == "-" ? UIColor(named: "Signature Red") : UIColor(named: "Signature Green")
            
            // Customize data views
            boxValue1.text = calculateMktCap(FD: false)
            boxValue2.text = calculateMktCap(FD: true)
            boxValue7.text = "#\(String(selectedCurrency!.cmc_rank))"
            boxValue4.text = String(Utilities.formatDecimal(selectedCurrency!.circulating_supply, with: ""))
            boxValue6.text = Utilities.formatDecimal(selectedCurrency!.total_supply, with: "")
            
            let unformattedVolume = Int(Utilities.getRate(for: selectedCurrency!, in: defaults.string(forKey: K.defaultFiat) ?? "USD").volume_24h)
            boxValue3.text = Utilities.formatDecimal(Double(unformattedVolume), with: "")
            
            if let maxSupply = selectedCurrency?.max_supply {
                boxValue5.text = Utilities.formatDecimal(Double(maxSupply), with: "")
            } else {
                boxValue5.text = "--"
            }
            
            let dominance = Utilities.getRate(for: selectedCurrency!, in: defaults.string(forKey:  K.defaultFiat) ?? "USD").market_cap_dominance
            boxValue8.text = String(format: "%.1f", dominance) + "%"
            
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
        if (selectedStock?.symbol) != nil {
            
            DispatchQueue.main.async {
                self.symbolLabel.text = self.selectedStock?.symbol
                self.nameLabel.text = self.selectedStock?.shortName
                self.priceLabel.text = "$\(self.selectedStock?.regularMarketPrice ?? 0.0)"
                self.boxValue4.text = Utilities.formatDecimal(Double(self.selectedStock!.averageDailyVolume10Day ?? 0), with: "")
                
                self.percentChangeLabel.text = String(format: "%.2f", self.selectedStock!.regularMarketChangePercent ?? 0.0) + "%"
                self.percentChangeLabel.textColor = self.percentChange.first == "-" ? UIColor(named: "Signature Red") : UIColor(named: "Signature Green")
                
                self.customizeViews()
                
                self.boxLabel2.text = "P/E"
                self.boxLabel5.text = "Low"
                self.boxLabel6.text = "High"
                
                self.boxValue3.text = Utilities.formatPriceLabel(String(format: "%.2f", (self.selectedStock!.trailingAnnualDividendYield ?? 0.0) * 100), with: "")
                self.boxValue1.text = Utilities.formatDecimal(Double(self.selectedStock!.marketCap ?? 0), with: "$")
                self.boxValue2.text = String(format: "%.2f", self.selectedStock!.trailingPE ?? 0.0)
                self.boxValue5.text = Utilities.formatPriceLabel(String(format: "%.2f", self.selectedStock!.regularMarketDayLow ?? 0.0), with: "$")
                self.boxValue6.text = Utilities.formatPriceLabel(String(format: "%.2f", self.selectedStock!.regularMarketDayHigh ?? 0.0), with: "$")
                self.boxValue7.text = Utilities.formatPriceLabel(String(format: "%.2f", self.selectedStock!.regularMarketOpen ?? 0.0), with: "$")
                self.boxValue8.text = Utilities.formatDecimal(Double(self.selectedStock!.regularMarketVolume ?? 0), with: "")
                self.boxValue9.text = Utilities.formatPriceLabel(String(format: "%.2f", self.selectedStock!.fiftyTwoWeekLow ?? 0.0), with: "$")
                self.boxValue10.text = Utilities.formatPriceLabel(String(format: "%.2f", self.selectedStock!.fiftyTwoWeekHigh ?? 0.0), with: "$")
            }
            
            DispatchQueue.main.async {
                // Setup chart view
                self.chartView.addSubview(self.lineChartView)
                self.lineChartView.centerInSuperview()
                self.lineChartView.width(to: self.chartView)
                self.lineChartView.height(to: self.chartView)
            }
            
            if let safeSymbol = selectedStock?.symbol {
                self.stockManager.performChartDataRequest(for: safeSymbol, in: self.timePeriod)
            }
            
        } else {
            print("No selected stock symbol")
        }
    }
    
    func customizeViews() {
        // Customize view
        view1.layer.cornerRadius = K.viewCornerRadius
        view2.layer.cornerRadius = K.viewCornerRadius
        view1.layer.cornerRadius = K.viewCornerRadius
        view3.layer.cornerRadius = K.viewCornerRadius
        view4.layer.cornerRadius = K.viewCornerRadius
        view5.layer.cornerRadius = K.viewCornerRadius
        view6.layer.cornerRadius = K.viewCornerRadius
        view7.layer.cornerRadius = K.viewCornerRadius
        view8.layer.cornerRadius = K.viewCornerRadius
        view9.layer.cornerRadius = K.viewCornerRadius
        view10.layer.cornerRadius = K.viewCornerRadius
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
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {}
    
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
    }
}


// MARK: - Stock Manager Delegate methds

extension GraphViewController: StockManagerDelegate {
    
    // Chart data for stock received, chart updated
    func receivedChartData(for data: ChartDataModel) {
        yValue = []
        var counter = 0.0
        let timestamps = data.chart.result[0].timestamp
        var prices = data.chart.result[0].indicators.quote[0].close
        
        // JSON may return null values for some prices
        var defaultPrice = prices[0]
        if defaultPrice == nil {
            for i in 0..<prices.count {
                if prices[i] != nil {
                    defaultPrice = prices[i]
                    break
                }
            }
        }
        
        for i in 0..<prices.count {
            if prices[i] == nil {
                if prices[i - 1] != nil {
                    prices[i] = prices[i - 1]
                } else {
                    prices[i] = defaultPrice
                }
            }
        }
        
        for _ in timestamps {
            yValue.append(ChartDataEntry(x: counter, y: prices[Int(counter)] ?? prices[Int(counter - 1)]!))
            counter += 1
        }
        DispatchQueue.main.async {
            self.setData()
        }
    }
    
    func receivedSymbolMetrics(for symbol: StockChartData) {}
    
    
    func receivedStockInformation() {
        selectedStock = stockManager.indexFundFullEntries[0]
        refreshStockInformation()
    }
    
    func receivedFavoriteStocks() {}
    func receivedSymbolInformatioN(for symbol: RecentStockData) {}
    
}
