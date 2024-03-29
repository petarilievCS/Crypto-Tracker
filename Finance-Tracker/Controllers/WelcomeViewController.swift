//
//  ViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 30.11.22.
//

import UIKit
import AudioToolbox
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var usernameField: UICustomTextField!
    @IBOutlet weak var passwordField: UICustomTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    
    let defaults = UserDefaults.standard
    var guest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guest = false
        
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
        guestButton.layer.cornerRadius = K.cornerRadius
        guestButton.layer.borderWidth = 2
        guestButton.layer.borderColor = UIColor.systemGray3.cgColor
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        // Check if user logged in
        if defaults.bool(forKey: K.rememberDevice) && Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: K.loginToStocksSegue, sender: self)
        }
    }
    
    @IBAction func guestButtonPressed(_ sender: UIButton) {
        guest = true
        performSegue(withIdentifier: K.loginToStocksSegue, sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        _ = loginUser()
    }
    
    // Dismiss keyboard upon tap
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Checks if user entered email
    func checkEmail() -> Bool {
        if usernameField.text!.isEmpty {
            return false
        } else if !Utilities.isValidEmail(usernameField.text!) {
            usernameField.text = ""
            usernameField.placeholder = "Enter a valid email"
            return false
        }
        return true
    }
    
    // Checks if user entered valid password
    func checkPassword() -> Bool {
        if passwordField.text!.isEmpty {
            return false
        }
        return true
    }
    
    // Attempts to login user
    func loginUser() -> Bool {
        var infoValid  = true
        
        if !checkEmail() {
            Utilities.shake(usernameField)
            infoValid = false
        }
        
        if !checkPassword() {
            Utilities.shake(passwordField)
            infoValid = false
        }
        
        if !infoValid {
            AudioServicesPlaySystemSound(1519)
        } else {
            // Login user
            Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!) { authResult, error in
                if error != nil {
                    AudioServicesPlaySystemSound(1519)
                    Utilities.shake(self.usernameField)
                    Utilities.shake(self.passwordField)
                    self.passwordField.text = ""
                    self.usernameField.text = ""
                    self.passwordField.placeholder = "Invalid information"
                    self.usernameField.placeholder = "Invalid information"
                } else {
                    // Ask user if they would like to stay logged in
                    Utilities.askForDefaultSignIn(in: self, to: "loginToStocks")
                }
            }
        }
        return infoValid
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.loginToStocksSegue {
            let destinationVC = segue.destination as! UITabBarController
            destinationVC.navigationItem.rightBarButtonItems?[0].isHidden = guest
        }
    }
}

// MARK: - Text Field delegate methods

extension WelcomeViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            if !checkEmail() {
                Utilities.shake(usernameField)
                AudioServicesPlaySystemSound(1519)
                return false
            }
        default:
            if !checkPassword() {
                Utilities.shake(passwordField)
                AudioServicesPlaySystemSound(1519)
                return false
            }
        }
        
        if textField.tag == 1 {
            textField.resignFirstResponder()
            return loginUser()
        }
        
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}

