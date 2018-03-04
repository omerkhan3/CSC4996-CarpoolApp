//
//  ViewProfileViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/3/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewProfileViewController: UIViewController {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var bio: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //When profile view is opened, it will show user details
        loadUserDetails()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editProfile(_ sender: Any) {
        //Reference storyboard and view controller with identifier we called "EditProfileView" as the edit profile view controller
        let editProfile = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileView") as! EditProfileViewController
       //Reference opener var and set to self which is our editprofileviewcontroller
        editProfile.opener = self
        
        //Go through navigation view controller and then present it
        let editProfileNav = UINavigationController(rootViewController: editProfile)
        self.present(editProfileNav, animated: true, completion: nil)
    }
    
    func loadUserDetails()
    {
        //The parse way was using the setObject
        
        let userFirstName = Auth.auth().currentUser!.value(forKey: "firstName") as! String
        let userLastName = Auth.auth().currentUser!.value(forKey: "lastName") as! String
        let phoneNumber = Auth.auth().currentUser!.value(forKey: "Phone") as! String
        let email = Auth.auth().currentUser!.value(forKey: "Email") as! String
        let bio = Auth.auth().currentUser!.value(forKey: "Biography") as! String
        
        firstNameField.text = userFirstName
        lastNameField.text = userLastName
        phoneNumberField.text = phoneNumber
        emailField.text = email
        bioField.text = bio
    }
}
