//
//  ViewController.swift
//  CarpoolApp
//
//  Created by Omer Khan on 1/27/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBOutlet weak var labelMessage: UILabel!
    
    
    
    @IBAction func registerButton(_ sender: UIButton)
    {
        let email = emailField.text
        let password = passwordField.text
        
        Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user: User?, error) in
            if error == nil {
                self.labelMessage.text = "You are successfully registered"
            }else{
                self.labelMessage.text = "Registration Failed.. Please Try Again"
            }
            
        })
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FirebaseApp.configure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

