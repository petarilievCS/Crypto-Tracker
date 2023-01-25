//
//  StocksViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 2.12.22.
//

import UIKit

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
        cell.stockLabel.text = indexFundEntries[indexPath.row].symbol
        cell.companyLabel.text = indexFundEntries[indexPath.row].name
        cell.priceLabel.text = ""
        cell.percentLabel.text = ""
        cell.logoImaeView.image = UIImage(named: "\(cell.stockLabel.text!.lowercased()).png")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexFundEntries.count
    }
}

// MARK: - Stock Manager Delegate methods

extension StocksViewController: StockManagerDelegate {
    func receivedStockInformation() {
        indexFundEntries = stockManager.indexFundEntries
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
