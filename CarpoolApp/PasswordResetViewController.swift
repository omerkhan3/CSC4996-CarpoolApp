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

class PasswordResetViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func resetButton(_ sender: UIButton) {
        
        
        let email = self.emailField.text
        
        var actionItem = ""
        var actionTitle = ""
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        if (email?.isEmpty)!
        {
            actionTitle = "Error!"
            actionItem = "The email field is empty."
            
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            
            alert.addAction(exitAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        Auth.auth().sendPasswordReset(withEmail: email!, completion: { (error) in
            
            if error != nil {
                actionTitle = "Error!"
                actionItem = (error?.localizedDescription)!
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                
                alert.addAction(exitAction)
                
                self.present(alert, animated: true, completion: nil)
            } else {
                actionTitle = "Success!"
                actionItem = "A link to reset your password has been sent to your email."
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                
                alert.addAction(exitAction)
                
                self.present(alert, animated: true, completion: nil)
                self.emailField.text = ""
            }

            

        })
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
