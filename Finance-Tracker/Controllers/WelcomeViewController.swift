//
//  ViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 30.11.22.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var usernameField: UICustomTextField!
    @IBOutlet weak var passwordField: UICustomTextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard upon tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Customize text fields and buttons
        usernameField.layer.cornerRadius = 25.0
        passwordField.layer.cornerRadius = 25.0
        loginButton.layer.cornerRadius = 25.0 
    }
    
    // Dismiss keyboard upon tap
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

