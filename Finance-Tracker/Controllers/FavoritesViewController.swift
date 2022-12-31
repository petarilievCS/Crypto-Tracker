//
//  StocksViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 1.12.22.
//

import UIKit

class FavoritesViewController: CryptoViewController {
    
    @IBOutlet weak var favoritesSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        self.searchBar = favoritesSearchBar
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Customize bar
        tableView.reloadData()
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.title = "Favorites"
    }
    
    // UITableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let favorites: [String] = (defaults.array(forKey: K.defaultFavorites) as? [String]) ?? []
        var count = 0
        for cryptoData in crypto {
            if favorites.contains(where: { str in
                return str == cryptoData.symbol
            }) {
                count += 1
            }
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.assetCellIdentifier) as! AssetCell
        let currentCrypto = findFavorite(at: indexPath.row)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        } else {
            performSegue(withIdentifier: K.favoritesToInfoSegue, sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Finds favorite crypto at given position
    func findFavorite(at position: Int) -> CryptoData {
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
        return currentCrypto!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case K.favoritesToInfoSegue:
            let destinationVC = segue.destination as! GraphViewController
            let selectedIdx = tableView.indexPathForSelectedRow!.row
            let selectedCurrency = findFavorite(at: selectedIdx)
            let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! AssetCell
            destinationVC.price = selectedCell.priceLabel.text!
            destinationVC.percentChange = selectedCell.percentLabel.text!
            destinationVC.selectedCurrency = selectedCurrency
        case K.cryptoToAccountSegue:
            print("Performing segue")
        default:
            fatalError("Segue identifier not handled")
        }
    }
    
}
