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
import FirebaseStorage
import SDWebImage

class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var UserFirstName: UILabel!
    @IBOutlet weak var UserLastName: UILabel!
    @IBOutlet weak var UserEmail: UILabel!
    @IBOutlet weak var UserPhoneNumber: UILabel!
    @IBOutlet weak var UserBio: UILabel!
    @IBOutlet weak var ProfilePic: UIImageView!
    
    @IBOutlet weak var UserFirstNameEdit: UITextField!
    @IBOutlet weak var UserEmailEdit: UITextField!
    @IBOutlet weak var UserLastNameEdit: UITextField!
    @IBOutlet weak var UserPhoneNumberEdit: UITextField!
    @IBOutlet weak var UserBioEdit: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var selectProfilePhoto: UIButton!
    
    let myPickerController = UIImagePickerController()
    
    @IBAction func selectProfilePhoto(_ sender: UIButton) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                myPickerController.sourceType = .camera
                self.present(myPickerController, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        ProfilePic.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    let dist = -140
    
    @IBAction func submitButton(_ sender: UIButton) {
        let userID = Auth.auth().currentUser!.uid
        let userInfo = ["userID": userID, "Biography": self.UserBioEdit.text as Any, "firstName": UserFirstNameEdit.text as Any, "lastName": UserLastNameEdit.text as Any, "Phone": UserPhoneNumberEdit.text as Any, "Email":  UserEmailEdit.text as Any] as [String : Any]
        
        updateProfile(userInfo: userInfo)
        updateImage()
        
        var actionItem : String=String()
        var actionTitle : String=String()
        let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)  // default action to exit out of native alerts.
        let emailEdit = UserEmailEdit.text
        let firstNameEdit = UserFirstNameEdit.text
        let lastNameEdit = UserLastNameEdit.text
        let phoneNumberEdit = UserPhoneNumberEdit.text
        let bioEdit = UserBioEdit.text
        
        //Error handling for if the user has not filled out all fields
        if ((emailEdit?.isEmpty)! || (firstNameEdit?.isEmpty)! || (lastNameEdit?.isEmpty)! || (phoneNumberEdit?.isEmpty)! || (bioEdit?.isEmpty)!)
        {
            actionTitle = "Error!"
            actionItem = "Please fill in all of the fields."
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil)
            
            self.UserFirstNameEdit.isHidden = false
            self.UserLastNameEdit.isHidden = false
            self.UserEmailEdit.isHidden = false
            self.UserPhoneNumberEdit.isHidden = false
            self.UserBioEdit.isHidden = false
            self.submitButton.isHidden = false
            
            self.UserFirstName.isHidden = true
            self.UserLastName.isHidden = true
            self.UserEmail.isHidden = true
            self.UserPhoneNumber.isHidden = true
            self.UserBio.isHidden = true
            self.ProfilePic.isHidden = true
        }
        else {
            var actionItem : String=String()
            var actionTitle : String=String()
            let exitAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)  // default action to exit out of native alerts.
            actionTitle = "Success!"
            actionItem = "Your profile has been successfully updated."
            
            // Activate UIAlertController to display error
            let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
            alert.addAction(exitAction)
            self.present(alert, animated: true, completion: nil) // present error alert.
            
            self.UserFirstName.isHidden = false
            self.UserLastName.isHidden = false
            self.UserEmail.isHidden = false
            self.UserPhoneNumber.isHidden = false
            self.UserBio.isHidden = false
            self.ProfilePic.isHidden = false
            
            self.UserFirstNameEdit.isHidden = true
            self.UserLastNameEdit.isHidden = true
            self.UserEmailEdit.isHidden = true
            self.UserPhoneNumberEdit.isHidden = true
            self.UserBioEdit.isHidden = true
            self.submitButton.isHidden = true
        }
        
        self.UserFirstName.text = self.UserFirstNameEdit.text
        self.UserLastName.text = self.UserLastNameEdit.text
        self.UserEmail.text = self.UserEmailEdit.text
        self.UserPhoneNumber.text = self.UserPhoneNumberEdit.text
        self.UserBio.text = self.UserBioEdit.text
    }
    
    @IBAction func editButton(_ sender: UIButton) {
        self.UserFirstNameEdit.text = self.UserFirstName.text
        self.UserLastNameEdit.text = self.UserLastName.text
        self.UserEmailEdit.text = self.UserEmail.text
        self.UserPhoneNumberEdit.text = self.UserPhoneNumber.text
        self.UserBioEdit.text = self.UserBio.text
        
        self.UserFirstName.isHidden = true
        self.UserLastName.isHidden = true
        self.UserEmail.isHidden = true
        self.UserPhoneNumber.isHidden = true
        self.UserBio.isHidden = true
        
        self.UserFirstNameEdit.isHidden = false
        self.UserLastNameEdit.isHidden = false
        self.UserEmailEdit.isHidden = false
        self.UserPhoneNumberEdit.isHidden = false
        self.UserBioEdit.isHidden = false
        self.ProfilePic.isHidden = false
        self.submitButton.isHidden = false
        self.selectProfilePhoto.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        if let userID = Auth.auth().currentUser?.uid {
            databaseRef.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? NSDictionary
                
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
            }) { (error) in
                print(error.localizedDescription)
                return
            }
        }
        let userID = Auth.auth().currentUser?.uid
        
        self.UserFirstNameEdit.isHidden = true
        self.UserLastNameEdit.isHidden = true
        self.UserEmailEdit.isHidden = true
        self.UserPhoneNumberEdit.isHidden = true
        self.UserBioEdit.isHidden = true
        self.submitButton.isHidden = true
        self.selectProfilePhoto.isHidden = true
        
        UserPhoneNumberEdit.delegate = self
        
        ProfilePic.layer.cornerRadius = ProfilePic.frame.size.width/2
        ProfilePic.clipsToBounds = true
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        loadProfileImage()
        readProfileInfo(userID: userID!)
        myPickerController.delegate = self
        let rightEditBarButtomItem: UIBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.editButton(_:)))
        
        self.navigationItem.setRightBarButton(rightEditBarButtomItem, animated: true)
    }

    func loadProfileImage()
    {
        if let userID = Auth.auth().currentUser?.uid {
            databaseRef.child("Users").child(userID).observe(.value, with: { (snapshot) in
                let values = snapshot.value as? NSDictionary
                if let profileImageURL = values?["Photo"] as? String {
                    self.ProfilePic.sd_setImage(with: URL(string: profileImageURL))
                }
            })
        }
    }
    
    func updateImage(){
        if let userID = Auth.auth().currentUser?.uid {
            let storageItem = storageRef.child("Photo").child(userID)
            guard let image = ProfilePic.image else {return}
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
                                self.UserFirstName.text =  (userInfo["firstName"] as! String)
                                self.UserLastName.text = (userInfo["lastName"] as! String)
                                self.UserEmail.text = (userInfo["Email"] as! String)
                                self.UserPhoneNumber.text = (userInfo["Phone"] as? String)
                                self.UserBio.text = (userInfo["Biography"] as? String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                    
                }
            }
            }.resume()
    }
    
    //For flipping the profile picture when camera is used, test which one works
    func rotateImage(image: UIImage) -> UIImage {
        
        if (image.imageOrientation == UIImageOrientation.up ) {
            return image
        }
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return copy!
    }
    //For flipping the profile picture when camera is used, test which one works
    func fixOrientation(img:UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveScrollView(textField, distance: dist, up: true)
        if (textField == self.UserPhoneNumberEdit) && textField.text == ""{
            textField.text = "+"
        }
    }
    
    //Phone number formatting
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.UserPhoneNumberEdit {
            let oldString = textField.text!
            let newString = oldString.replacingCharacters(in: Range(range, in: oldString)!, with: string)
            
            let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            let numString = components.joined(separator: "")
            let length = numString.count
            
            if newString.count < oldString.count && newString.count >= 1 {
                return true
            }
            if length < 1 || length > 11 {
                return false
            }
            
            var indexStart, indexEnd: String.Index
            var maskString = "", template = ""
            var endOffset = 0
            
            if length >= 1 {
                maskString += "+"
                indexStart = numString.index(numString.startIndex, offsetBy: 0)
                indexEnd = numString.index(numString.startIndex, offsetBy: 1)
                maskString += String(numString[indexStart..<indexEnd]) + " ("
            }
            if length > 1 {
                endOffset = 4
                template = ") "
                if length < 4 {
                    endOffset = length
                    template = ""
                }
                indexStart = numString.index(numString.startIndex, offsetBy: 1)
                indexEnd = numString.index(numString.startIndex, offsetBy: endOffset)
                maskString += String(numString[indexStart..<indexEnd]) + template
            }
            if length > 4 {
                endOffset = 7
                template = "-"
                if length < 7 {
                    endOffset = length
                    template = ""
                }
                indexStart = numString.index(numString.startIndex, offsetBy: 4)
                indexEnd = numString.index(numString.startIndex, offsetBy: endOffset)
                maskString += String(numString[indexStart..<indexEnd]) + template
            }
            if length > 7 {
                indexStart = numString.index(numString.startIndex, offsetBy: 7)
                indexEnd = numString.index(numString.startIndex, offsetBy: length)
                maskString += String(numString[indexStart..<indexEnd])
            }
            
            textField.text = maskString
            if (length == 11) {
                textField.endEditing(true)
            }
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Detatch listener
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
