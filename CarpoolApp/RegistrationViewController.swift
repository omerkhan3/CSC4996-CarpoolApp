//
//  RegistrationViewController.swift
//  CarpoolApp
//
//  Created by Omer  Khan on 1/31/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegistrationViewController: UIViewController, UITextFieldDelegate {
    
    // UI components
    @IBOutlet weak var firstNameField: UITextField! // first name text field.
    @IBOutlet weak var lastNameField: UITextField! // last name text field.
    @IBOutlet weak var emailField: UITextField! // email text field.
    @IBOutlet weak var passwordField: UITextField! // password text field.
    @IBOutlet weak var confirmPasswordField: UITextField! // confirm password text field.
    
    let dist = -250 // distance to adjust for keyboard
    
    // Register button isClicked method
    @IBAction func registerButton(_ sender: UIButton) {// on click of the register button.
        var actionItem = ""
        var actionTitle = ""
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)  // default action to exit out of native alerts.
        let email = emailField.text
        let password = passwordField.text
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let confirmPassword = confirmPasswordField.text
        
        // Error handling for if the user has not filled out all fields.
        if ((email?.isEmpty)! || (password?.isEmpty)!||(firstName?.isEmpty)! || (lastName?.isEmpty)! || (confirmPassword?.isEmpty)!)
        {
            actionTitle = "Error!"
            actionItem = "You have not entered all required information."
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)
        }
        // Error handling to make sure passwords match.
        else if (password != self.confirmPasswordField.text)
        {
            actionTitle = "Error!"
            actionItem = "Passwords do not match.  Please try again."
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        // Firebase query to create a user.
        else{
        Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user: User?, error) in
            if error == nil {
                actionTitle = "Success!"
                actionItem = "Congratulations, you have successfully registered!"
                
                // Activate UIAlertController to display confirmation
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(exitAction)
                self.present(alert, animated: true, completion: nil)
                
                // Create new user entry in database
                let userInfo = ["provider": user?.providerID as Any, "firstName": self.firstNameField.text as Any, "lastName": self.lastNameField.text as Any, "email": email as Any] as [String:Any] // store information that user has submitted in a dictionary.
                DataService.inst.createUser(id: (user?.uid)!, userInfo: userInfo)  // we userInfo to store data in the DB under the user's unique identifier.
                
                // Error handling
            }else{
                actionTitle = "Error!"
                actionItem = (error?.localizedDescription)!
                
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(exitAction)
                
                self.present(alert, animated: true, completion: nil)
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
