//
//  AccountViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 31.12.22.
//

import UIKit

class AccountViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.accountTableViewCellIdentifier)!
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Logout"
        case 1:
            cell.textLabel?.text = "Delete Account"
            cell.textLabel?.textColor = UIColor(named: "Signature Red")
        default:
            fatalError("No such cell")
        }
        
        return cell
    }

}
