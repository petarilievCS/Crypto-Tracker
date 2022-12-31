//
//  AccountViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 31.12.22.
//

import UIKit
import Firebase
import FirebaseAuth

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            logout()
        case 1:
            deleteAccount()
        default:
            fatalError("No such cell")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func deleteAccount() {
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            let user = Auth.auth().currentUser
            user?.delete { error in
                if error != nil {
                fatalError("Error while deleting account")
              } else {
                print("Account deleted")
              }
            }
            self.performSegue(withIdentifier: K.accountToLoginSegue, sender: self)
        }
        let noAction = UIAlertAction(title: "No", style: .default)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }
    
    // Logout user
    @objc func logout() {
        let alert = UIAlertController(title: "", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
           let firebaseAuth = Auth.auth()
           do {
             try firebaseAuth.signOut()
               self.performSegue(withIdentifier: K.accountToLoginSegue, sender: self)
           } catch let signOutError as NSError {
             print("Error signing out: %@", signOutError)
           }
        }
        let noAction = UIAlertAction(title: "No", style: .default)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }

}
