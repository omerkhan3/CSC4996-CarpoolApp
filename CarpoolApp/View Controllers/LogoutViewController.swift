//
//  LogoutViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 2/7/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LogoutViewController: UIViewController {
    
    func logoutButton(){
        if Auth.auth().currentUser != nil {
            do {
                try?Auth.auth().signOut()
                
                if Auth.auth().currentUser == nil {
                    let LogoutViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Logout") as! LogoutViewController
                    self.present(LogoutViewController, animated: true, completion: nil)
                    print("Logout Successful")
                }
            }
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutButton()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

