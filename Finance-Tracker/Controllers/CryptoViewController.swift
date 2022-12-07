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

    override func viewDidLoad() {
        
        // Dismiss keyboard upon tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        tableView.register(UINib(nibName: K.assetCellIdentifier, bundle: nil), forCellReuseIdentifier: K.assetCellIdentifier)
        
        // Refresh functionality
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshInformation), for: .valueChanged)
        self.tabBarController?.navigationItem.rightBarButtonItems?[0] = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshInformation))
        
        searchBar.delegate = self
        cryptoManager.delegate = self
        cryptoManager.performRequest()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Customize bar
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.title = "Crypto"
    }
    
    // MARK: - Table View methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crypto.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.assetCellIdentifier) as! AssetCell
        let currentCrypto = crypto[indexPath.row]
        cell.circleImageView.layer.cornerRadius = 32.0
        cell.priceLabel.text = "$" + String(format: "%.2f", currentCrypto.quote.USD.price)
        cell.stockLabel.text = currentCrypto.symbol
        cell.companyLabel.text = currentCrypto.name
        
        let percentChange = currentCrypto.quote.USD.percent_change_24h
        cell.percentLabel.textColor = percentChange >= 0 ? UIColor(named: "Signature Green") : UIColor(named: "Signature Red")
        cell.percentLabel.text = String(format: "%.2f", currentCrypto.quote.USD.percent_change_24h) + "%"
        
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
