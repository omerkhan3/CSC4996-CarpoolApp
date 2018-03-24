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
    @IBOutlet weak var ProfilePic: UIImageView!
    @IBAction func editButton(_ sender: Any) {
    }
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Code for getting profile pic from firebase using email moe4@test.com
        databaseRef = Database.database().reference()
        if let userID = Auth.auth().currentUser?.uid {
            databaseRef.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? NSDictionary
                
                let firstName = dictionary?["firstName"] as? String ?? "First Name"
                let lastName = dictionary?["lastName"] as? String ?? "Last Name"
                let email = dictionary?["email"] as? String ?? "Email Address"
                let phoneNumber = dictionary?["phone"] as? String ?? "Phone Number"
                let bio = dictionary?["bio"] as? String ?? "Bio"
                
                if let profileImageURL = dictionary?["Photo"] as? String {
                    let url = URL(string: profileImageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: {
                        (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            self.ProfilePic.image = UIImage(data: data!)
                        }
                    }).resume()
                }
                self.UserFirstName.text = firstName
                self.UserLastName.text = lastName
                self.UserPhoneNumber.text = phoneNumber
                self.UserEmail.text = email
                self.UserBio.text = bio
            }) { (error) in
                print(error.localizedDescription)
                return
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
