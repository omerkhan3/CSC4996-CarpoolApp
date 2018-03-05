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
import FirebaseDatabase

class EditProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var bioField: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func doneButton(_ sender: Any) {
    }
    @IBAction func saveButton(_ sender: Any) {
        //Get the current user
        let userID = Auth.auth().currentUser!.uid
        
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
                    print(data)
                    let userInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                    if let data = userInfoString.data(using: String.Encoding.utf8.rawValue) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                            print (json as Any)
                            if let userInfo = json!["data"]
                            {
                                DispatchQueue.main.async {
                                    self.firstNameField.text =  (userInfo["firstName"] as! String)
                                    self.lastNameField.text = (userInfo["lastName"] as! String)
                                    self.emailField.text = (userInfo["Email"] as! String)
                                    self.phoneNumberField.text = (userInfo["Phone"] as! String)
                                    self.bioField.text = (userInfo["Biography"] as! String)
                                }
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                }
                }.resume()
        }
        
        
        //Checking to see if all the fields are empty
        if(lastNameField.text!.isEmpty && firstNameField.text!.isEmpty && bioField.text!.isEmpty && phoneNumberField.text!.isEmpty && emailField.text!.isEmpty) {
            
            let myAlert = UIAlertController(title: "Alert", message: "All fields can't be empty", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
            return
        }
        
        //Making sure that each field is required, checking to see if any is empty
        if(firstNameField.text!.isEmpty || lastNameField.text!.isEmpty || bioField.text!.isEmpty || emailField.text!.isEmpty || phoneNumberField.text!.isEmpty) {
            
            let myAlert = UIAlertController(title: "Alert", message: "First name and last name are required fields", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
            return
        }
    }
    
    let dist = -190
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneNumberField.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Only numbers can be inputted in phone number field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    //Limiting bio field to 150 characters
    /*func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == bioField {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let changedText = currentText.replacingCharacters(in: stringRange, with: text)
            return changedText.count <= 150
        }
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }*/
    
    // Keyboard handling
    // Begin editing within text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveScrollView(textField, distance: dist, up: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let scrollPoint: CGPoint = CGPoint.init(x: 0, y: 200)
        self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    // End editing within text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveScrollView(textField, distance: dist, up: false)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
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
