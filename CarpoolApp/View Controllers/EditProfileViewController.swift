//
//  EditProfileViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/4/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var bioField: UITextView!
    @IBAction func saveButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
