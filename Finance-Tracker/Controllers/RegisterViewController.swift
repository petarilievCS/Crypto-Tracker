//
//  RegisterViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 1.12.22.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var firstNameField: UICustomTextField!
    @IBOutlet weak var lastNameField: UICustomTextField!
    @IBOutlet weak var emailField: UICustomTextField!
    @IBOutlet weak var passwordField: UICustomTextField!
    @IBOutlet weak var passwordField2: UICustomTextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard upon tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        // Hide back button
        navigationItem.hidesBackButton = true
        
        // Customize buttons and text fields
        firstNameField.layer.cornerRadius = K.cornerRadius
        lastNameField.layer.cornerRadius = K.cornerRadius
        emailField.layer.cornerRadius = K.cornerRadius
        passwordField.layer.cornerRadius = K.cornerRadius
        passwordField2.layer.cornerRadius = K.cornerRadius
        signUpButton.layer.cornerRadius = K.cornerRadius
    }
    
    // Dismiss keyboard upon tap
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
