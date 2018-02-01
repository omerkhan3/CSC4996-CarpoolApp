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

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    
    
    @IBAction func loginButton(_ sender: Any) {
        let email = self.emailField.text
        let password = self.passwordField.text
        
        var actionItem = ""
        var actionTitle = ""
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        if ((email?.isEmpty)! || (password?.isEmpty)!)
        {
            actionTitle = "Error!"
            actionItem = "You have not entered all required information."
            
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            
            alert.addAction(exitAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        else{
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            
            if error == nil {
                actionTitle = "Success!"
                actionItem = "You have successfully logged in!"
                
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(exitAction)
                
                self.present(alert, animated: true, completion: nil)
            } else {
                
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
