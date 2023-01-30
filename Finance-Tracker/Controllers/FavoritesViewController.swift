//
//  StocksViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 1.12.22.
//

import UIKit

class FavoritesViewController: CryptoViewController {
    
    @IBOutlet weak var favoritesSearchBar: UISearchBar!
    
    var cryptoCount: Int = 0
    var stockCount: Int = 0
    var isSelectedCellStock: Bool = false
    
    override func viewDidLoad() {
        self.searchBar = favoritesSearchBar
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Customize bar
        tableView.reloadData()
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.title = "Favorites"
        tabBarController?.navigationItem.rightBarButtonItems?[1].isHidden = true
    }
    
    // UITableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let favorites: [String] = (defaults.array(forKey: K.defaultFavorites) as? [String]) ?? []
        cryptoCount = 0
        for cryptoData in crypto {
            if favorites.contains(where: { str in
                return str == cryptoData.symbol
            }) {
                cryptoCount += 1
            }
        }
        var stockCount = 0
        for stockData in indexFundEntries {
            if favorites.contains(where: { str in
                return str == stockData.symbol
            }) {
                stockCount += 1
            }
        }
        
        if section == 0 { return cryptoCount }
        return stockCount
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Crypto"
        case 1:
            return "Stocks"
        default:
            return  "Else"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.assetCellIdentifier) as! AssetCell
        cell.circleImageView.layer.cornerRadius = 32.0
        
        // Crypto
        if indexPath.section == 0 {
            let currentCrypto = findFavorite(at: indexPath.row)
            cell.stockLabel.text = currentCrypto?.symbol
            cell.companyLabel.text = currentCrypto?.name
            
            setCurrencyInCell(cell, for: currentCrypto!)
            
            if let cryptoIcon = UIImage(named: "\(currentCrypto!.symbol.lowercased()).png") {
                cell.logoImaeView.contentMode = .scaleAspectFit
                cell.logoImaeView.image = cryptoIcon
            } else {
                cell.logoImaeView.image = UIImage(named: "generic.svg")
            }
        }
        // Stocks
        else {
            let currentStock  = findFavoriteStock(at: indexPath.row)
            cell.stockLabel.text = currentStock?.symbol
            cell.companyLabel.text = currentStock?.name
            cell.priceLabel.text = ""
            cell.percentLabel.text = ""
            
            if let stockIcon = UIImage(named: "\(currentStock?.symbol.lowercased() ?? "aapl").png") {
                cell.logoImaeView.contentMode = .scaleAspectFit
                cell.logoImaeView.image = stockIcon
            } else {
                cell.logoImaeView.image = UIImage(named: "generic.svg")
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            isSelectedCellStock = true
        } else {
            isSelectedCellStock = false
        }
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        } else {
            performSegue(withIdentifier: K.favoritesToInfoSegue, sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Finds favorite stock at given position
    func findFavoriteStock(at position: Int) -> IndexEntry? {
        var current = 0
        var currentStock: IndexEntry? = nil
        let favorites = defaults.array(forKey: K.defaultFavorites) as! [String]
        
        for stockData in indexFundEntries {
            if favorites.contains(where: { str in
                return str == stockData.symbol
            }) {
                if position == current {
                    currentStock = stockData
                    break
                }
                current += 1
            }
        }
        return currentStock
    }
    
    // Finds favorite crypto at given position
    func findFavorite(at position: Int) -> CryptoData? {
        var current = 0
        var currentCrypto: CryptoData? = nil
        let favorites = defaults.array(forKey: K.defaultFavorites) as! [String]
        
        for cryptoData in crypto {
            if favorites.contains(where: { str in
                return str == cryptoData.symbol
            }) {
                if position == current {
                    currentCrypto = cryptoData
                    break
                }
                current += 1
            }
        }
        return currentCrypto
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case K.favoritesToInfoSegue:
            let destinationVC = segue.destination as! GraphViewController
            let selectedIdx = tableView.indexPathForSelectedRow!.row
            let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! AssetCell
            if !isSelectedCellStock {
                print("Presenting crypt VC")
                let selectedCurrency = findFavorite(at: selectedIdx)
                destinationVC.price = selectedCell.priceLabel.text!
                destinationVC.percentChange = selectedCell.percentLabel.text!
                destinationVC.selectedCurrency = selectedCurrency
                destinationVC.isStocks = false
            } else {
                print("Presenting stock VC")
                let selectedStock = findFavoriteStock(at: selectedIdx)
                destinationVC.isStocks = true
                destinationVC.selectedStock = selectedStock
                
            }
        default:
            print("Segue identifier not handled")
        }
    }
    
    override func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        crypto = crypto.filter({ coin in
            let query = searchBar.text!.lowercased()
            let coinName = coin.name.lowercased()
            let coinSymbol = coin.symbol.lowercased()
            return coinName.contains(query) || coinSymbol.contains(query)
        })
        indexFundEntries = indexFundEntries.filter({ entry in
            let query = searchBar.text!.lowercased()
            let entryName = entry.name.lowercased()
            let entrySymbol = entry.symbol.lowercased()
            return entryName.contains(query) || entrySymbol.contains(query)
        })
        self.tableView.reloadData()
    }
    
    override func refreshInformation() {
        cryptoManager.performRequest()
        stockManager.performRequest()
        
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            refreshInformation()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
