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
import FirebaseStorage
import SDWebImage

class EditProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var EmailAddress: UILabel!
    @IBOutlet weak var PhoneNumber: UILabel!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var PhoneField: UITextField!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var bioField: UITextView!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    
    @IBAction func doneButton(_ sender: Any) {
        var actionItem: String=String()
        var actionTitle: String=String()
        
        actionTitle = "Warning!"
        actionItem = "Are you sure you want to exit out of the edit page?"
        
        let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            let profileview = self.storyboard?.instantiateViewController(withIdentifier: "ProfileView")
            self.present(profileview!, animated: true, completion: nil)
        }
        let exitaction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        alert.addAction(action)
        alert.addAction(exitaction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectProfilePhoto(_ sender: Any) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.allowsEditing = false
        myPickerController.sourceType = .photoLibrary
        myPickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage = UIImage()
        print(info)
        selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        profilePicture.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        updateImage()
        
        var actionItem: String=String()
        var actionTitle: String=String()
        
        let userID = Auth.auth().currentUser!.uid
        let userInfo = ["userID": userID, "Biography": self.bioField.text! as Any, "firstName": self.firstNameField.text! as Any, "lastName": self.lastNameField.text! as Any, "Phone": self.PhoneField.text! as Any, "Email": self.EmailField.text! as Any]
        updateProfile(userInfo: userInfo)
        updateImage()
        
        actionTitle = "Success!"
        actionItem = "Your profile information has been saved"
        
        let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            let profileview = self.storyboard?.instantiateViewController(withIdentifier: "ProfileView")
            self.present(profileview!, animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    let dist = -20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        loadProfileData()
        readProfileInfo(userID: userID!)
    }
    
    func loadProfileData()
    {
        if let userID = Auth.auth().currentUser?.uid {
            databaseRef.child("Users").child(userID).observe(.value, with: { (snapshot) in
                let values = snapshot.value as? NSDictionary
                if let profileImageURL = values?["Photo"] as? String {
                    self.profilePicture.sd_setImage(with: URL(string: profileImageURL))
                }
            })
        }
    }
    
    func updateImage(){
        if let userID = Auth.auth().currentUser?.uid {
            let storageItem = storageRef.child("Photo").child(userID)
            guard let image = profilePicture.image else {return}
            if let newImage = UIImagePNGRepresentation(image)
            {
                storageItem.putData(newImage, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    storageItem.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        if let profilePhotoURL = url?.absoluteString {
                            
                            let newPhoto = ["Photo": profilePhotoURL]
                            
                            self.databaseRef.child("Users").child(userID).updateChildValues(newPhoto, withCompletionBlock: { (error, ref) in
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                print("Profile Successfully Updated")
                            })
                        }
                    })
                })
            }
        }
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
                                self.EmailField.text = (userInfo["Email"] as! String)
                                self.PhoneField.text = (userInfo["Phone"] as? String)
                                self.bioField.text = (userInfo["Biography"] as? String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    func updateProfile(userInfo: Dictionary<String, Any>)
        {
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
