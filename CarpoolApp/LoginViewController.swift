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


class LoginViewController: UIViewController, UITextFieldDelegate{
    
    // UI components
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let dist = -200 // distance to adjust for keyboard
    
    
    
    // Login button isPressed method
    @IBAction func loginButton(_ sender: Any) {
        
        // Get email and password from fields
        let email = self.emailField.text
        let password = self.passwordField.text
        
        var actionItem = ""
        var actionTitle = ""
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        
        // Check that both fields are completed
        if ((email?.isEmpty)! || (password?.isEmpty)!)
        {
            actionTitle = "Error!"
            actionItem = "You have not entered all required information."
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)
        } else {
        
        // Firebase authenication
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            // Check login successful
            if error == nil {
                actionTitle = "Success!"
                actionItem = "You have successfully logged in!"
                
                // Activate UIAlertController to display confirmation
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(exitAction)
                self.present(alert, animated: true, completion: nil)
                
                DataService.inst.setUserLocation(location: CLLocation(latitude: 37.7853889, longitude: -122.4056973))
                
            } else {
                // Login error handling
                actionTitle = "Error!"
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
