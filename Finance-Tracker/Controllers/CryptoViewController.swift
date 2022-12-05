//
//  CryptoViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 2.12.22.
//

import UIKit

class CryptoViewController: UITableViewController {
    
    var crypto: [Crypto] = []
    let cryptoManager = CryptoManager()

    override func viewDidLoad() {
        tableView.register(UINib(nibName: K.assetCellIdentifier, bundle: nil), forCellReuseIdentifier: K.assetCellIdentifier)
        cryptoManager.performRequests()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Customize bar
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.title = "Crypto"
        crypto = cryptoManager.returnArray
        tableView.reloadData()
    }
    
    // MARK: - Table View methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crypto.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.assetCellIdentifier) as! AssetCell
        let currentCrypto = crypto[indexPath.row]
        cell.circleImageView.layer.cornerRadius = 32.0
        cell.priceLabel.text = String(format: "%.2f", currentCrypto.rate)
        cell.stockLabel.text = currentCrypto.asset_id_base
        cell.companyLabel.text = ""
        cell.percentLabel.text = ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}
