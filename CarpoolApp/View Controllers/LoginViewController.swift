//
//  LoginViewController.swift
//  CarpoolApp
//
//  Created by Omer  Khan on 1/31/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MapKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // UI components
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dashboardButton: RoundedButton!
    
    let dist = 0 // distance to adjust for keyboard
    
    // Login button isPressed method
    @IBAction func loginButton(_ sender: Any) {
        
        // Get email and password from fields
        let email = self.emailField.text
        let password = self.passwordField.text
        
        var actionItem : String=String()
        var actionTitle : String=String()
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)  // default action to exit out of native alerts.
        
        // Check that both fields are completed
        if ((email?.isEmpty)! || (password?.isEmpty)!)
        {
            actionTitle = "Error!"
            actionItem = "You have not entered all required information."
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)  // present error alert.
            
        } else {
        
        // Firebase authenication query for login.
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in

            if error == nil {
                if Auth.auth().currentUser?.isEmailVerified == true {
                    // Segue to dashboard
                    self.performSegue(withIdentifier: "showDashboard", sender: self)
                } else {
                    actionTitle = "Error!"
                    actionItem = "Please verify your email address by following the link provided. Would you like for us to resend the link?"
                    
                    // Activate UIAlertController to display error
                    let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        // resend verification email
                        Auth.auth().currentUser?.sendEmailVerification{ (error) in
                            print("email auth sent")
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    }))
                    self.present(alert, animated: true, completion: nil)  // present error alert.
                }

            } else {
                // Login error handling
                actionTitle = "Error!"

                actionItem = (error?.localizedDescription)!

                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(exitAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "loginView"
        self.navigationController?.navigationBar.isHidden = true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        moveScrollView(textField, distance: dist, up: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        moveScrollView(textField, distance: dist, up: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }

    func moveScrollView(_ textField: UITextField, distance: Int, up: Bool) {
        
        let movement: CGFloat = CGFloat(up ? distance: -distance)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
    }
}
