//
//  ViewProfileViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/3/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

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
        var editProfile = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileView") as! EditProfileViewController
       //Reference opener var and set to self which is our editprofileviewcontroller
        editProfile.opener = self
        
        //Go through navigation view controller and then present it
        let editProfileNav = UINavigationController(rootViewController: editProfile)
        self.presentViewController(editProfileNav, animated: true, completion: nil)
    }
    
    func loadUserDetails()
    {
        let userFirstName = Auth.auth().currentUser!.objectForKey("") as! String
        let userLastName = Auth.auth().currentUser!.objectForKey("") as! String
        let phoneNumber = Auth.auth().objectForKey("") as! String
        let email = Auth.auth().currentUser!.objectForKey("") as! String
        let bio = Auth.auth().currentUser!.objectForKey("") as! String
        
        firstNameField.text = userFirstName
        lastNameField.text = userLastName
        phoneNumberField.text = phoneNumber
        emailField.text = email
        bioField.text = bio
    }

}
