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
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard upon tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Customize text fields and buttons
        usernameField.layer.cornerRadius = K.cornerRadius
        passwordField.layer.cornerRadius = K.cornerRadius
        loginButton.layer.cornerRadius = K.cornerRadius
        registerButton.layer.cornerRadius = K.cornerRadius
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = UIColor.systemGray3.cgColor
    }
    
    // Dismiss keyboard upon tap
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

