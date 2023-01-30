//
//  StocksViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 2.12.22.
//

import UIKit
import SwiftYFinance

class StocksViewController: CryptoViewController {

    @IBOutlet weak var newSearchBar: UISearchBar!
    
 
    
    override func viewDidLoad() {
        self.searchBar = newSearchBar
        super.viewDidLoad()
        
        stockManager.delegate = self
        stockManager.performRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Customize bar
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.title = "Stocks"
        tabBarController?.navigationItem.rightBarButtonItems?[1].isHidden = true
    }
    
    // MARK: - Table View methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.assetCellIdentifier, for: indexPath) as! AssetCell
        
        let currentStock = indexFundEntries[indexPath.row]
        cell.stockLabel.text = currentStock.symbol
        cell.companyLabel.text = currentStock.name
        cell.priceLabel.text = ""
        cell.percentLabel.text = ""
        
        var imageName = "\(cell.stockLabel.text!.lowercased()).png"
        if imageName == "payx.png" {
            imageName = "payxx.png" // Edge case: crypto and stock have same symbol
        }
        cell.logoImaeView.image = UIImage(named: imageName) ?? UIImage(named: "generic.svg")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexFundEntries.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        } else {
            performSegue(withIdentifier: K.stocksToGraphSegue, sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Reloads most recent data
    @objc override func refreshInformation() {
        stockManager.performRequest()
        
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }
 
}


// MARK: - Segue methods

extension StocksViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case K.stocksToGraphSegue:
            let destinationVC = segue.destination as! GraphViewController
            let selectedStock = indexFundEntries[tableView.indexPathForSelectedRow!.row]
            destinationVC.isStocks = true
            destinationVC.selectedStock = selectedStock
        case K.cryptoToAccountSegue:
            print("Works")
        default:
            fatalError("Segue identifier not handled")
        }
    }
}

// MARK: - Search Bar Delegate methods

extension StocksViewController {
    
    override func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        indexFundEntries = indexFundEntries.filter({ entry in
            let query = searchBar.text!.lowercased()
            let entryName = entry.name.lowercased()
            let entrySymbol = entry.symbol.lowercased()
            return entryName.contains(query) || entrySymbol.contains(query)
        })
        self.tableView.reloadData()
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
