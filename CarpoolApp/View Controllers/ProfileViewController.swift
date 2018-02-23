//
//  ProfileViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 2/4/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {
    @IBOutlet weak var UserFirstName: UILabel!
    @IBOutlet weak var UserLastName: UILabel!
    @IBOutlet weak var UserEmail: UILabel!
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    var sideMenuHidden = true
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        if sideMenuHidden {
            sideMenuConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
                })
        } else {
            sideMenuConstraint.constant = -230
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        sideMenuHidden = !sideMenuHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        readProfileInfo(userID: userID!)
        
        // Initialize constant with -230 (hide side menu)
        sideMenuConstraint.constant = -230
    }

    func readProfileInfo(userID: String)
    {
        var viewProfileComponents = URLComponents(string: "http://localhost:3000/users/profile")!
        viewProfileComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewProfileComponents.url!)  // Pass Parameter in URL
        print (viewProfileComponents.url!)

        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
             let userInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = userInfoString.data(using: String.Encoding.utf8.rawValue) {
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        if let userInfo = json
                        {
                            DispatchQueue.main.async {
                                self.UserFirstName.text =  (userInfo["firstName"] as! String)
                                self.UserLastName.text = (userInfo["lastName"] as! String)
                                self.UserEmail.text = (userInfo["email"] as! String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                    
                }
            }
            
            }.resume()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Attach listener to each view that needs sign-in user information
    // Listens for auth state
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Attatch listener
//        let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//
//        }
    }
    
    // Detatch listener
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        Auth.auth().removeStateDidChangeListener(handle!)
    }
}
