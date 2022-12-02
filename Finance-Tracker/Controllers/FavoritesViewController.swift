//
//  StocksViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 1.12.22.
//

import UIKit

class FavoritesViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Dismiss keyboard upon tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        tableView.register(UINib(nibName: K.assetCellIdentifier, bundle: nil), forCellReuseIdentifier: K.assetCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Customize bar
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.title = "Favorites"
    }
    
    // Dismiss keyboard upon tap
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Table View Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.assetCellIdentifier, for: indexPath) as! AssetCell
        cell.circleImageView.layer.cornerRadius = 32.0
        
        // For UI purposes
        switch indexPath.row {
        case 1:
            cell.stockLabel.text = "NKE"
            cell.companyLabel.text = "Nike Inc."
            cell.priceLabel.text = "$110.45"
            cell.percentLabel.text = "-17.28%"
            return cell
        case 2:
            cell.stockLabel.text = "TSLA"
            cell.companyLabel.text = "Tesla"
            cell.priceLabel.text = "$240.45"
            cell.percentLabel.text = "-10.34%"
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }

}
