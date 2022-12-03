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
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        passwordField2.delegate = self
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        if createUser() {
            performSegue(withIdentifier: "registerToStocks", sender: self)
        }
    }
    
    // Dismiss keyboard upon tap
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // Checks if a string is a valid email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Checks if first name entered is valid
    func checkFirstName() -> Bool {
        return !firstNameField.text!.isEmpty
    }
    
    // Checks if last name entered is valid
    func checkLastName() -> Bool {
        return !lastNameField.text!.isEmpty
    }
    
    // Checks if user entered valid email
    func checkEmail() -> Bool {
        if emailField.text!.isEmpty {
            return false
        } else if !isValidEmail(emailField.text!) {
            emailField.placeholder = "Enter a valid email..."
            return false
        }
        return true
    }
    
    // Checks if user entered valid password
    func checkPassword() -> Bool {
        if passwordField.text!.isEmpty {
            return false
        } else if passwordField.text!.count < 6 {
            passwordField.text = ""
            passwordField2.text = ""
            passwordField.placeholder = "Password is too short..."
            return false
        }
        return true
    }
    
    // Checks second password field
    func checkPassword2() -> Bool {
        if passwordField2.text!.isEmpty {
            return false
        } else if passwordField.text != passwordField2.text {
            passwordField2.text = ""
            passwordField2.placeholder = "Passwords do not match"
            return false
        }
        return true
    }
    
    // Creates a user in Firebase server
    func createUser() -> Bool {
        
        var infoValid = true
        
        if !checkFirstName() {
            shake(firstNameField)
            infoValid = false
        }
        
        if !checkLastName() {
            shake(lastNameField)
            infoValid = false
        }
        
        if !checkEmail() {
            shake(emailField)
            infoValid = false
        }
        
        if !checkPassword() {
            shake(passwordField)
            infoValid = false
        }
        
        if !checkPassword2() {
            shake(passwordField2)
            infoValid = false
        }
        
        if !infoValid {
            AudioServicesPlaySystemSound(1519)
        } else {
            // Register user
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { authResult, error in
                if error != nil {
                    print ("Error with user creation")
                }
            }
        }
        return infoValid
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

// MARK: -  Text Field delegate methods

extension RegisterViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            if !checkFirstName() {
                shake(firstNameField)
                AudioServicesPlaySystemSound(1519)
                return false
            }
        case 1:
            if !checkLastName() {
                shake(lastNameField)
                AudioServicesPlaySystemSound(1519)
                return false
            }
        case 2:
            if !checkEmail() {
                shake(emailField)
                AudioServicesPlaySystemSound(1519)
                return false
            }
        case 3:
            if !checkPassword() {
                shake(passwordField)
                AudioServicesPlaySystemSound(1519)
                return false
            }
        default:
            if !checkPassword2() {
                shake(passwordField2)
                AudioServicesPlaySystemSound(1519)
                return false
            }
        }
        
        if textField.tag == 4 {
            // Present next VC
            if createUser() {
                performSegue(withIdentifier: "registerToStocks", sender: self)
                return true
            }
        }
        
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        
        // Do not add a line break
        return false
    }
}
