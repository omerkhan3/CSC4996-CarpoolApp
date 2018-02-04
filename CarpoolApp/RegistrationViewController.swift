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
import MapKit

class RegistrationViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    
    @IBAction func registerButton(_ sender: UIButton) {
    
        
        
        var actionItem = ""
        var actionTitle = ""
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        let email = emailField.text
        let password = passwordField.text
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let confirmPassword = confirmPasswordField.text
        
        if ((email?.isEmpty)! || (password?.isEmpty)!||(firstName?.isEmpty)! || (lastName?.isEmpty)! || (confirmPassword?.isEmpty)!)
        {
            actionTitle = "Error!"
            actionItem = "You have not entered all required information."
            
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            
            alert.addAction(exitAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        else if (password != self.confirmPasswordField.text)
        {
            actionTitle = "Error!"
            actionItem = "Passwords do not match.  Please try again."
            
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            
            alert.addAction(exitAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        else{
        Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user: User?, error) in
            if error == nil {
                actionTitle = "Success!"
                actionItem = "Congratulations, you have successfully registered!"
                
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(exitAction)
                
                self.present(alert, animated: true, completion: nil)
                
                let userInfo = ["provider": user?.providerID as Any, "firstName": self.firstNameField.text as Any, "lastName": self.lastNameField.text as Any, "email": email as Any] as [String:Any]
                
                DataService.inst.createUser(id: (user?.uid)!, userInfo: userInfo)
                
                
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
