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
    
    var indexFundEntries: [IndexEntry] = []
    let stockManager = StockManager()
    
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
        cell.logoImaeView.image = UIImage(named: imageName)
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
}

// MARK: - Stock Manager Delegate methods

extension StocksViewController: StockManagerDelegate {
    
    func receivedSymbolInformatioN(for symbol: RecentStockData) {}
    
    func receivedStockInformation() {
        indexFundEntries = stockManager.indexFundEntries
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
