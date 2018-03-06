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
    @IBOutlet weak var UserPhoneNumber: UILabel!
    @IBOutlet weak var UserBio: UILabel!
    @IBAction func editButton(_ sender: Any) {
    }
    
    //var userProfile = [Profile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        readProfileInfo(userID: userID!)
    }

    func readProfileInfo(userID: String)
    {
        var viewProfileComponents = URLComponents(string: "http://141.217.48.15:3000/users/profile")!
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
                print(data)
             let userInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = userInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        print (json as Any)
                        if let userInfo = json!["data"]
                        {
                            DispatchQueue.main.async {
                                self.UserFirstName.text =  (userInfo["firstName"] as! String)
                                self.UserLastName.text = (userInfo["lastName"] as! String)
                                self.UserEmail.text = (userInfo["Email"] as! String)
                                self.UserPhoneNumber.text = (userInfo["Phone"] as? String)
                                self.UserBio.text = (userInfo["Biography"] as? String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                    
                }
            }
            
            }.resume()
    }
    
//    // Download notifications JSON and decode into an array
//    func getProfile(completed: @escaping () -> ()) {
//        // get userID
//        let userID = Auth.auth().currentUser?.uid
//        var viewProfileComponents = URLComponents(string: "http://localhost:3000/users/profile")!
//        viewProfileComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
//        var request = URLRequest(url: viewProfileComponents.url!)  // Pass Parameter in URL
//        print (viewProfileComponents.url!)
//
//        request.httpMethod = "GET" // GET METHOD
//        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
//            if (error != nil){  // error handling responses.
//                print (error as Any)
//            } else {
//                guard let data = data else { return }
//                do {
//                    // decode JSON into Notifications[] array type
//                    self.userProfile = try JSONDecoder().decode([Profile].self, from: data)
//                    print(self.userProfile)
//                    DispatchQueue.main.async {
//                        self.UserFirstName.text = self.userProfile[0].firstName
//                        self.UserLastName.text = self.userProfile[0].lastName
//                        self.UserEmail.text = self.userProfile[0].email
//                        self.UserPhoneNumber.text = self.userProfile[0].phone
//                        self.UserBio.text = self.userProfile[0].biography
//                        completed()
//                    }
//                } catch let jsnErr {
//                    print(jsnErr)
//                }
//            }
//            }.resume()
//    }
    
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
