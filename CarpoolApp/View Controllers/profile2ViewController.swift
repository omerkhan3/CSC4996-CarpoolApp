//
//  profileView2ViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 2/26/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class profile2ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var bioField: UITextField!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var Bio: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let dist = -190
    
    @IBAction func editButton(_ sender: Any) {
        
    }
    @IBAction func SaveButton(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        readProfileInfo(userID: userID!)
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
                                self.firstName.text = (userInfo["firstName"] as! String)
                                self.lastName.text = (userInfo["lastName"] as! String)
                                //self.phoneNumber.text = (userInfo["phoneNumber"] as! String)
                                //self.Email.text = (userInfo["Email"] as! String)
                                //self.Bio.text = (userInfo["Bio"] as! String)
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
