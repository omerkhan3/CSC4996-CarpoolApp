//
//  EditProfileViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/4/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var bioField: UITextView!
    @IBAction func saveButton(_ sender: Any) {
        var actionItem: String=String()
        var actionTitle: String=String()
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        let userID = Auth.auth().currentUser!.uid
        let userInfo = ["userID": userID, "Biography": self.bioField.text] as [String : Any]
        updateProfile(userInfo: userInfo)
        actionTitle = "Success!"
        actionItem = "Your profile information has been saved"
        
        let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
        alert.addAction(exitAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    let dist = -20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateProfile(userInfo: Dictionary<String, Any>)
    {
        //Users folder is on database but /profile isn't, where is this URL location
        let editProfileURL = URL(string: "http://localhost:3000/users/profile")!
        var request = URLRequest(url: editProfileURL)
        let userJSON = try! JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        let userJSONInfo = NSString(data: userJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "userInfo=\(userJSONInfo)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST" // POST method.
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print ("An error has occured.")
            }
            else{
                print ("Success!")
            }
            
            }.resume()
    }
    
    // Keyboard handling
    // Begin editing within text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveScrollView(textField, distance: dist, up: true)
    }
    
    // End editing within text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveScrollView(textField, distance: dist, up: false)
    }
    
    // Hide keyboard if return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move scroll view
    func moveScrollView(_ textField: UITextField, distance: Int, up: Bool) {
        let movement: CGFloat = CGFloat(up ? distance: -distance)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
    }
}
