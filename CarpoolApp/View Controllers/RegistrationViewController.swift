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
    @IBOutlet weak var phoneNumberField: UITextField! // phone number text field
    
    let dist = -140 // distance to adjust for keyboard
    
    // Register button isClicked method
    @IBAction func registerButton(_ sender: UIButton) {// on click of the register button.
        var actionItem : String=String()
        var actionTitle : String=String()
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)  // default action to exit out of native alerts.
        let email = emailField.text
        let password = passwordField.text
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let confirmPassword = confirmPasswordField.text
        let phoneNumber = phoneNumberField.text
        
        // Error handling for if the user has not filled out all fields.
        if ((email?.isEmpty)! || (password?.isEmpty)!||(firstName?.isEmpty)! || (lastName?.isEmpty)! || (confirmPassword?.isEmpty)! || (phoneNumber?.isEmpty)!)
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
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.performSegue(withIdentifier: "showLogin", sender: self)
                }))
                self.present(alert, animated: true, completion: nil)
                
                let userID = (user?.uid) ?? "Unknown"
                let provider = (user?.providerID) ?? "Unknown"
                let firstName = self.firstNameField.text ?? "Unknown"
                let lastName = self.lastNameField.text ?? "Unknown"
                let email = self.emailField.text ?? "Unknown"
                let phone = self.phoneNumberField.text ?? "Unknown"
                // Create new user entry in database
                let userInfo = ["userID": userID,   "provider": provider, "firstName": firstName, "lastName": lastName, "email": email, "phone": phone] as [String:Any] // store information that user has submitted in a dictionary.
               // DataService.inst.createUser(id: (user?.uid)!, userInfo: userInfo)  // we userInfo to store data in the DB under the user's unique identifier.

                self.storeUserInfo(userInfo: userInfo)
                
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == self.phoneNumberField) && textField.text == ""{
            textField.text = "+"
        }
        moveScrollView(textField, distance: dist, up: true)
    }
    
    //Phone number formatting
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.phoneNumberField {
            let oldString = textField.text!
            let newString = oldString.replacingCharacters(in: Range(range, in: oldString)!, with: string)
            
            let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            let numString = components.joined(separator: "")
            let length = numString.count
            
            if newString.count < oldString.count && newString.count >= 1 {
                return true
            }
            if length < 1 || length > 11 {
                return false
            }
            
            var indexStart, indexEnd: String.Index
            var maskString = "", template = ""
            var endOffset = 0
            
            if length >= 1 {
                maskString += "+"
                indexStart = numString.index(numString.startIndex, offsetBy: 0)
                indexEnd = numString.index(numString.startIndex, offsetBy: 1)
                maskString += String(numString[indexStart..<indexEnd]) + " ("
            }
            if length > 1 {
                endOffset = 4
                template = ") "
                if length < 4 {
                    endOffset = length
                    template = ""
                }
                indexStart = numString.index(numString.startIndex, offsetBy: 1)
                indexEnd = numString.index(numString.startIndex, offsetBy: endOffset)
                maskString += String(numString[indexStart..<indexEnd]) + template
            }
            if length > 4 {
                endOffset = 7
                template = "-"
                if length < 7 {
                    endOffset = length
                    template = ""
                }
                indexStart = numString.index(numString.startIndex, offsetBy: 4)
                indexEnd = numString.index(numString.startIndex, offsetBy: endOffset)
                maskString += String(numString[indexStart..<indexEnd]) + template
            }
            if length > 7 {
                indexStart = numString.index(numString.startIndex, offsetBy: 7)
                indexEnd = numString.index(numString.startIndex, offsetBy: length)
                maskString += String(numString[indexStart..<indexEnd])
            }
            
            textField.text = maskString
            if (length == 11) {
                textField.endEditing(true)
            }
            return false
        }
        return true
    }
    
    func storeUserInfo(userInfo: Dictionary<String, Any>)
    {
        let registrationURL = URL(string: "http://141.217.48.15:3000/users/register")!
        var request = URLRequest(url: registrationURL)
        let userJSON = try! JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        let userJSONInfo = NSString(data: userJSON, encoding: String.Encoding.utf8.rawValue)! as String
                request.httpBody = "userInfo=\(userJSONInfo)".data(using: String.Encoding.utf8)
                request.httpMethod = "POST" // POST method.
                
                URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                    if (error != nil){  // error handling responses.
                        print ("An error has occured.")
                    }
                    else{
                        print ("Success!")
                    }
                    
                    }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
