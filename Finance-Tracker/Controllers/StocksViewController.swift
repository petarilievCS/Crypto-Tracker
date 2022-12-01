//
//  StocksViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 1.12.22.
//

import UIKit

class StocksViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Dismiss keyboard upon tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Hide back button
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.title = "Stocks"
        tabBarController?.tabBar.frame.size.height = 100.0
        tabBarController?.tabBar.frame.origin.y = view.frame.height - 100.0
        
        tableView.register(UINib(nibName: K.assetCellIdentifier, bundle: nil), forCellReuseIdentifier: K.assetCellIdentifier)
    }
    
    // Dismiss keyboard upon tap
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Table View Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.assetCellIdentifier, for: indexPath) as! AssetCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

}
