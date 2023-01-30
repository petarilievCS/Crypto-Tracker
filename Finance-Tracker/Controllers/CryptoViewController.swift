//
//  CryptoViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 2.12.22.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftYFinance

class CryptoViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var crypto: [CryptoData] = []
    let cryptoManager = CryptoManager()
    var fiatCurrencies = ["USD", "EUR", "GBP", "JPY", "KRW", "INR", "CAD", "HKD", "AUD", "TWD", "BRL", "CHF"]
    let defaults = UserDefaults.standard
    
    var indexFundEntries: [IndexEntry] = []
    let stockManager = StockManager()

    override func viewDidLoad() {
        tableView.register(UINib(nibName: K.assetCellIdentifier, bundle: nil), forCellReuseIdentifier: K.assetCellIdentifier)
        
        // Refresh functionality
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshInformation), for: .valueChanged)
        // self.tabBarController?.navigationItem.rightBarButtonItems?[0] = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshInformation))
        self.tabBarController?.navigationItem.rightBarButtonItems?[0] = UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: self, action: #selector(goToAccount))
        
        // Currency change
        fiatCurrencies.sort()
        self.tabBarController?.navigationItem.rightBarButtonItems?[1] = UIBarButtonItem(image: UIImage(systemName: "dollarsign"), style: .plain, target: self, action: #selector(changeCurrency))
        
        searchBar.delegate = self
        cryptoManager.delegate = self
        cryptoManager.performRequest()
        stockManager.delegate = self
        stockManager.performRequest()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Customize bar
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.title = "Crypto"
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
        tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    // MARK: - Table View methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crypto.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.assetCellIdentifier) as! AssetCell
        let currentCrypto = crypto[indexPath.row]
        cell.circleImageView.layer.cornerRadius = 32.0
        cell.stockLabel.text = currentCrypto.symbol
        cell.companyLabel.text = currentCrypto.name
        
        setCurrencyInCell(cell, for: currentCrypto)
        
        if let cryptoIcon = UIImage(named: "\(currentCrypto.symbol.lowercased()).png") {
            cell.logoImaeView.contentMode = .scaleAspectFit
            cell.logoImaeView.image = cryptoIcon
        } else {
            cell.logoImaeView.image = UIImage(named: "generic.svg")
        }
         
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        } else {
            performSegue(withIdentifier: K.crytpoToInfoSegue, sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
              
    // Dismiss keyboard upon tap
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
              
    // Reloads most recent data
    @objc func refreshInformation() {
        cryptoManager.performRequest()
        
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }
    
    // Take user to account VC
    @objc func goToAccount() {
        performSegue(withIdentifier: K.cryptoToAccountSegue, sender: self)
    }
    
    // Changes the currency in which the value of crypto is shown
    @objc func changeCurrency() {
        let alert = UIAlertController(title: "Change Currency", message: "", preferredStyle: .alert)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 150, height: 200))
        let action = UIAlertAction(title: "Change", style: .default) { action in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            self.defaults.set(self.fiatCurrencies[selectedRow], forKey: K.defaultFiat)
            self.refreshInformation()
        }
        alert.addAction(action)
        alert.view.tintColor = UIColor(named: "Signature Green")
        
        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 150,height: 200)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(currentCurrencyRow(), inComponent: 0, animated: false)
        viewController.view.addSubview(pickerView)
        alert.setValue(viewController, forKey: "contentViewController")
        
        present(alert, animated: true)
    }
    
    // Returns row number of current selected currency
    func currentCurrencyRow() -> Int {
        let currency = defaults.string(forKey: K.defaultFiat) ?? "USD"
        for row in 0..<fiatCurrencies.count {
            if fiatCurrencies[row] == currency {
                return row
            }
        }
        return 0
    }
}

// MARK: - Crypto Manager Delegate methods

extension CryptoViewController: CryptoManagerDelegate {
    func receivedInformation() {
        crypto = cryptoManager.returnArray
        self.tableView.reloadData()
    }
}

// MARK: - Search Bar Delegate methods

extension CryptoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        crypto = crypto.filter({ coin in
            let query = searchBar.text!.lowercased()
            let coinName = coin.name.lowercased()
            let coinSymbol = coin.symbol.lowercased()
            return coinName.contains(query) || coinSymbol.contains(query)
        })
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            refreshInformation()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

// MARK: - UI Picker View methods

extension CryptoViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fiatCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fiatCurrencies[row]
    }
    
}

// MARK: - Segue methods

extension CryptoViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case K.crytpoToInfoSegue:
            let destinationVC = segue.destination as! GraphViewController
            let selectedCurrency = crypto[tableView.indexPathForSelectedRow!.row]
            let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! AssetCell
            destinationVC.isStocks = false
            destinationVC.price = selectedCell.priceLabel.text!
            destinationVC.percentChange = selectedCell.percentLabel.text!
            destinationVC.selectedCurrency = selectedCurrency
        default:
            print("Segue identifier not handled")
        }
    }
}

// MARK: - Fiat currency methods

extension CryptoViewController {
    
    // Changes the rates according to the new currency
    func setCurrencyInCell(_ cell: AssetCell, for currentCrypto: CryptoData) {
        
        let fiatCurrency = defaults.string(forKey: K.defaultFiat) ?? "USD"
        let symbol = Utilities.getSymbol(for: fiatCurrency)
        let rate = Utilities.getRate(for: currentCrypto, in: fiatCurrency)
        
        if rate.price > 1 {
            cell.priceLabel.text = symbol + String(format: "%.2f", rate.price)
        } else {
            cell.priceLabel.text = symbol + String(format: "%.5f", rate.price)
            while cell.priceLabel.text?.last == "0" {
                cell.priceLabel.text?.removeLast()
            }
        }
        
        let percentChange = rate.percent_change_24h
        cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
        cell.percentLabel.text = String(format: "%.2f", rate.percent_change_24h) + "%"
        
        if rate.price > 1 {
            // Format price
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            var stringPrice = cell.priceLabel.text!
            var fiatSymbol = ""
            fiatSymbol += String(stringPrice.removeFirst())
            
            // BRL currency has two characters
            if fiatCurrency == "BRL" {
                fiatSymbol += String(stringPrice.removeFirst())
            }
            
            let doublePrice = Double(stringPrice)!
            cell.priceLabel.text = fiatSymbol + numberFormatter.string(from: NSNumber(value: doublePrice))!
        }
    }
}

// MARK: - Stock Manager Delegate methods

extension CryptoViewController: StockManagerDelegate {
    
    func receivedChartData(for data: [StockChartData]) {}
    
    
    func receivedStockInformation() {
        self.indexFundEntries = stockManager.indexFundEntries
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func receivedSymbolInformatioN(for symbol: RecentStockData) {}
    
    func receivedSymbolMetrics(for symbol: StockChartData) {}
    
    
}
