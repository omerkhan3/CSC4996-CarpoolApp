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
    
    var ref: DatabaseReference! // Creates database reference
    var refHandle: UInt! // Create reference handle

    @IBOutlet weak var UserFirstName: UILabel!
    @IBOutlet weak var UserLastName: UILabel!
    @IBOutlet weak var UserEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reference database data
        ref = Database.database().reference()
        
        // Reference user data
            let userID = Auth.auth().currentUser?.uid
            ref = Database.database().reference().child("Users")
                // Create reference to child node
        
        readProfileInfo(userID: userID!)
            ref.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let userEmail = value?["email"] as? String ?? ""
                let firstName = value?["firstName"] as? String ?? ""
                let lastName = value?["lastName"] as? String ?? ""
                self.UserFirstName.text = firstName
                self.UserLastName.text = lastName
                self.UserEmail.text = userEmail
                print("UserID: ")
                print(userID!)
                print("Email: ")
                print(userEmail)
                print("firstNAme: ")
                print(firstName)
                print("lastName: ")
                print(lastName)
            }) { (error) in
                print(error.localizedDescription)
            }
    }

    func readProfileInfo(userID: String)
    {
        var viewProfileComponents = URLComponents(string: "http://localhost:3000/viewProfile/")!
        viewProfileComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewProfileComponents.url!)
        print (viewProfileComponents.url!)

        request.httpMethod = "GET" // POST method.
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print ("An error has occured.")
            }
            else{
                print ("Success!")
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
