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
    @IBOutlet weak var emailField: UITextField! // email text field.
    @IBOutlet weak var passwordField: UITextField! // password text field.
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
        if ((email?.isEmpty)! || (password?.isEmpty)!)  // error handling for if all fields were filled  out.
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
            
            // Check login successful
            if error == nil {
                self.performSegue(withIdentifier: "showDashboard", sender: self)
//                if Auth.auth().currentUser?.isEmailVerified == true {
//                    // Segue to dashboard
//
//                } else {
//                    actionTitle = "Error!"
//                    actionItem = "Please verify your email address by following the link provided. Would you like for us to resend the link?"
//
//                    // Activate UIAlertController to display error
//                    let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                        // resend verification email
//                            Auth.auth().currentUser?.sendEmailVerification{ (error) in
//                            print("email auth sent")
//                        }
//                    }))
//                    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
//                    }))
//                    self.present(alert, animated: true, completion: nil)  // present error alert.
//                }
//
            } else {
                // Login error handling
                actionTitle = "Error!"
                
                // "localizedDescription" provides feedback as to what the error is.
                actionItem = (error?.localizedDescription)!
                
                // Activate UIAlertController to display confirmation
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
    }

    // Keyboard handling
    // Begin editing within text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        moveScrollView(textField, distance: dist, up: true)
    }
    
    // End editing within text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        moveScrollView(textField, distance: dist, up: false)
    }
    
    // Hide keyboard if return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // Move scroll view
    func moveScrollView(_ textField: UITextField, distance: Int, up: Bool) {
        
        let movement: CGFloat = CGFloat(up ? distance: -distance)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
    }
}
