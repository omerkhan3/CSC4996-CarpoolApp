//
//  LogoutViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 2/7/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

class LogoutViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let exitAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { ACTION in print("You have successfully logged out")
    })
    
    @IBAction func logOut(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(exitAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
    }
}
    

    /*func createAlert (title:String, message:String)
    {
        createAlert(title: "WARNING!", message: "Are you sure you want to log out?")
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (action) in alert.dismiss(animated: true , completion: nil)
            print("Cancel")
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            (action) in alert.dismiss(animated: true , completion: nil)
            print("OK")
        }))
        self.present(alert, animated: true, completion: nil)
    }*/

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

