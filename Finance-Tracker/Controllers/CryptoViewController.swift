//
//  CryptoViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 2.12.22.
//

import UIKit

class CryptoViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var crypto: [CryptoData] = []
    let cryptoManager = CryptoManager()
    var fiatCurrencies = ["USD", "EUR", "GBP", "JPY", "KRW", "INR", "CAD", "HKD", "AUD", "TWD", "BRL", "CHF"]
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        
        // Dismiss keyboard upon tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        tableView.register(UINib(nibName: K.assetCellIdentifier, bundle: nil), forCellReuseIdentifier: K.assetCellIdentifier)
        
        // Refresh functionality
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshInformation), for: .valueChanged)
        self.tabBarController?.navigationItem.rightBarButtonItems?[0] = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshInformation))
        
        // Currency change
        fiatCurrencies.sort()
        self.tabBarController?.navigationItem.rightBarButtonItems?[1] = UIBarButtonItem(image: UIImage(systemName: "dollarsign"), style: .plain, target: self, action: #selector(changeCurrency))
        
        searchBar.delegate = self
        cryptoManager.delegate = self
        cryptoManager.performRequest()
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
        cell.logoImaeView.image = UIImage(named: "\(currentCrypto.id).png")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
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
        tableView.reloadData()
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
        tableView.reloadData()
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

// MARK: - Fiat currency methods

extension CryptoViewController {
    
    // Changes the rates according to the new currency
    func setCurrencyInCell(_ cell: AssetCell, for currentCrypto: CryptoData) {
        let fiatCurrency = defaults.string(forKey: K.defaultFiat) ?? "USD"
        switch fiatCurrency {
        case "EUR":
            cell.priceLabel.text = "€" + String(format: "%.2f", currentCrypto.quote.EUR.price)
            let percentChange = currentCrypto.quote.EUR.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.EUR.percent_change_24h) + "%"
        case "GBP":
            cell.priceLabel.text = "£" + String(format: "%.2f", currentCrypto.quote.GBP.price)
            let percentChange = currentCrypto.quote.GBP.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.GBP.percent_change_24h) + "%"
        case "JPY":
            cell.priceLabel.text = "¥" + String(format: "%.2f", currentCrypto.quote.JPY.price)
            let percentChange = currentCrypto.quote.JPY.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.JPY.percent_change_24h) + "%"
        case "CAD":
            cell.priceLabel.text = "$" + String(format: "%.2f", currentCrypto.quote.CAD.price)
            let percentChange = currentCrypto.quote.CAD.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.CAD.percent_change_24h) + "%"
        case "CHF":
            cell.priceLabel.text = "₣" + String(format: "%.2f", currentCrypto.quote.CHF.price)
            let percentChange = currentCrypto.quote.CHF.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.CHF.percent_change_24h) + "%"
        case "KRW":
            cell.priceLabel.text = "₩" + String(format: "%.2f", currentCrypto.quote.KRW.price)
            let percentChange = currentCrypto.quote.KRW.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.KRW.percent_change_24h) + "%"
        case "INR":
            cell.priceLabel.text = "₹" + String(format: "%.2f", currentCrypto.quote.INR.price)
            let percentChange = currentCrypto.quote.INR.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.INR.percent_change_24h) + "%"
        case "HKD":
            cell.priceLabel.text = "$" + String(format: "%.2f", currentCrypto.quote.HKD.price)
            let percentChange = currentCrypto.quote.HKD.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.HKD.percent_change_24h) + "%"
        case "AUD":
            cell.priceLabel.text = "$" + String(format: "%.2f", currentCrypto.quote.AUD.price)
            let percentChange = currentCrypto.quote.AUD.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.AUD.percent_change_24h) + "%"
        case "TWD":
            cell.priceLabel.text = "$" + String(format: "%.2f", currentCrypto.quote.TWD.price)
            let percentChange = currentCrypto.quote.TWD.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.TWD.percent_change_24h) + "%"
        case "BRL":
            cell.priceLabel.text = "R$" + String(format: "%.2f", currentCrypto.quote.BRL.price)
            let percentChange = currentCrypto.quote.BRL.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.BRL.percent_change_24h) + "%"
        default:
            cell.priceLabel.text = "$" + String(format: "%.2f", currentCrypto.quote.USD.price)
            let percentChange = currentCrypto.quote.USD.percent_change_24h
            cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
            cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.USD.percent_change_24h) + "%"
        }
        
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
        
        var doublePrice = Double(stringPrice)!
        cell.priceLabel.text = fiatSymbol + numberFormatter.string(from: NSNumber(value: doublePrice))!
    }
}
