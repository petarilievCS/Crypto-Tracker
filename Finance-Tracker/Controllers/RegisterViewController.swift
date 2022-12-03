//
//  RegisterViewController.swift
//  Finance-Tracker
//
//  Created by Petar Iliev on 1.12.22.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import AudioToolbox

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
        
        // Customize buttons and text fields
        firstNameField.layer.cornerRadius = K.cornerRadius
        lastNameField.layer.cornerRadius = K.cornerRadius
        emailField.layer.cornerRadius = K.cornerRadius
        passwordField.layer.cornerRadius = K.cornerRadius
        passwordField2.layer.cornerRadius = K.cornerRadius
        signUpButton.layer.cornerRadius = K.cornerRadius
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        // Check for validity of information
        if checkName() {
            performSegue(withIdentifier: "registerToStocks", sender: self)
        } else {
            // vibrate
            AudioServicesPlaySystemSound(1519)
        }
        
    }
    
    // Dismiss keyboard upon tap
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Checks if the user entered a valid name and last name
    func checkName() -> Bool {
        var nameIsValid = true
        
        if firstNameField.text?.isEmpty ?? true {
            firstNameField.placeholder = "Please enter your name..."
            shake(firstNameField)
            nameIsValid = false
        }
        
        if lastNameField.text?.isEmpty ?? true {
            lastNameField.placeholder = "Please enter your last name..."
            shake(lastNameField)
            nameIsValid = false
        }
        
        return nameIsValid
        
    }
    
    // Creates a basic shake animation for the text fields
    func shake(_ viewToShake: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x - 10, y: viewToShake.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x + 10, y: viewToShake.center.y))
        viewToShake.layer.add(animation, forKey: "position")
    }

}
