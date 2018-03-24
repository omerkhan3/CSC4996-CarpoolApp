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
        alert.addAction(action)
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
        updateProfile()
        
        var actionItem: String=String()
        var actionTitle: String=String()
        
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
        loadProfileData()
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
    }
    
    func loadProfileData()
    {
        databaseRef = Database.database().reference()
        if let userID = Auth.auth().currentUser?.uid {
            databaseRef.child("Users").child(userID).observe(.value, with: { (DataSnapshot) in
                let values = DataSnapshot.value as? NSDictionary
                if let profileImageURL = values?["Photo"] as? String {
                    self.profilePicture.sd_setImage(with: URL(string: profileImageURL))
                }
                self.firstNameField.clearsOnBeginEditing = true
                self.firstNameField.text = values?["firstName"] as? String
                
                self.lastNameField.clearsOnBeginEditing = true
                self.lastNameField.text = values?["lastName"] as? String
                
                self.EmailField.clearsOnBeginEditing = true
                self.EmailField.text = values?["email"] as? String
                
                self.PhoneField.clearsOnBeginEditing = true
                self.PhoneField.text = values?["Phone"] as? String
                
                self.bioField.text = values?["bio"] as? String
            })
        }
    }
    
    func updateProfile(){
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
                            guard let newFirstName = self.firstNameField.text else {return}
                            guard let newLastName = self.lastNameField.text else {return}
                            guard let newbio = self.bioField.text else {return}
                            guard let newEmail = self.EmailField.text else {return}
                            
                            let newValuesForProfile = ["Photo": profilePhotoURL,"firstName": newFirstName, "lastName": newLastName, "email": newEmail, "bio": newbio]
                            
                            self.databaseRef.child("Users").child(userID).updateChildValues(newValuesForProfile, withCompletionBlock: { (error, ref) in
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
