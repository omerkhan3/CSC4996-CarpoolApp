//
//  PasswordResetViewController.swift
//  CarpoolApp
//
//  Created by Omer  Khan on 1/31/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PasswordResetViewController: UIViewController, UITextFieldDelegate {
    
    // UI components
    @IBOutlet weak var emailField: UITextField!
    
    let dist = -100 // distance to adjust for keyboard
    
    // Reset button isPressed method
    @IBAction func resetButton(_ sender: UIButton) {
        
        // Get email from field
        let email = self.emailField.text
        
        var actionItem = ""
        var actionTitle = ""
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        // Check that email field has been completed
        if (email?.isEmpty)!
        {
            actionTitle = "Error!"
            actionItem = "The email field is empty."
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)
        } else {
        // Firebase password reset function
        Auth.auth().sendPasswordReset(withEmail: email!, completion: { (error) in
            
            // Reset error handling
            if error != nil {
                actionTitle = "Error!"
                actionItem = (error?.localizedDescription)!
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                
                alert.addAction(exitAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                // If reset successful
                actionTitle = "Success!"
                actionItem = "A link to reset your password has been sent to your email."
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                
                alert.addAction(exitAction)
                
                self.present(alert, animated: true, completion: nil)
                self.emailField.text = ""
            }
        })
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
