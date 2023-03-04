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
        getFavoriteStocks()
        getFavoriteCrypto()
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.title = "Favorites"
        tabBarController?.navigationItem.rightBarButtonItems?[1].isHidden = true
    }
    
    // UITableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return favoriteCrypto.count
        }
        return favoriteStocks.count
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
            
            if let safeCrypto = currentCrypto {
                setCurrencyInCell(cell, for: safeCrypto)
                if let cryptoIcon = UIImage(named: "\(currentCrypto!.symbol.lowercased()).png") {
                    cell.logoImaeView.contentMode = .scaleAspectFit
                    cell.logoImaeView.image = cryptoIcon
                } else {
                    cell.logoImaeView.image = UIImage(named: "generic.svg")
                }
            } else {
                cell.logoImaeView.image = nil
            }
        }
        // Stocks
        else {
            let currentStock  = favoriteStocks[indexPath.row]
            cell.stockLabel.text = currentStock.symbol
            cell.companyLabel.text = currentStock.shortName
            cell.priceLabel.text = Utilities.formatPriceLabel(String(currentStock.regularMarketPrice ?? 0.0), with: "$")
            
            let percentChange: Double = currentStock.regularMarketChangePercent ?? 0.0
            cell.percentLabel.text = String(format: "%.2f", percentChange)
            cell.percentLabel.text! += "%"
            cell.percentLabel.textColor = percentChange < 0 ? UIColor(named: "Signature Red") : UIColor(named: "Signature Green")
            
            var imageName = "\(cell.stockLabel.text!.lowercased()).png"
            var upperCaseImageName = "\(cell.stockLabel.text!).png"
            
            if stockManager.edgeCaseSet.contains(cell.stockLabel.text!.lowercased()) {
                upperCaseImageName = "\(cell.stockLabel.text!) 1.png"
            }
            
            // Putting upper case first takes care of all edge cases where crypto and stock have the same symbol
            cell.logoImaeView.image = UIImage(named: upperCaseImageName) ?? UIImage(named: imageName) ?? UIImage(named: "default.png")
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
    
   
    
 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case K.favoritesToInfoSegue:
            let destinationVC = segue.destination as! GraphViewController
            let selectedIdx = tableView.indexPathForSelectedRow!.row
            let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! AssetCell
            if !isSelectedCellStock {
                let selectedCurrency = findFavorite(at: selectedIdx)
                destinationVC.price = selectedCell.priceLabel.text!
                destinationVC.percentChange = selectedCell.percentLabel.text!
                destinationVC.selectedCurrency = selectedCurrency
                destinationVC.isStocks = false
            } else {
                let selectedStock = favoriteStocks[selectedIdx]
                destinationVC.isStocks = true
                destinationVC.selectedStock = selectedStock
                
            }
        default:
            print("Segue identifier not handled")
        }
    }
    
    override func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        favoriteCrypto = favoriteCrypto.filter({ coin in
            let query = searchBar.text!.lowercased()
            let coinName = coin.name.lowercased()
            let coinSymbol = coin.symbol.lowercased()
            return coinName.contains(query) || coinSymbol.contains(query)
        })
        favoriteStocks = favoriteStocks.filter({ entry in
            let query = searchBar.text!.lowercased()
            let entryName = entry.shortName?.lowercased() ?? "Name not found"
            let entrySymbol = entry.symbol.lowercased()
            return entryName.contains(query) || entrySymbol.contains(query)
        })
        self.tableView.reloadData()
    }
    
    override func refreshInformation() {
        cryptoManager.performRequest()
        stockManager.performRequest()
        getFavoriteStocks()
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

