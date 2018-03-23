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
            databaseRef.child("Users").child(userID).observeSingleEvent(of: .value, with: { (DataSnapshot) in
                let dictionary = DataSnapshot.value as? NSDictionary
                
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
        readProfileInfo(userID: userID!)
        //readImage(userID: userID!)
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
                                //self.ProfilePic.image = (userInfo["Photo"] as? UIImage)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    /*func readImage(userID: String)
    {
        var viewProfileComponents = URLComponents(string: "http://localhost:3000/users/image")!
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
                                self.ProfilePic.image = (userInfo["Photo"] as! UIImage)
                            }
                        }
                    }catch let error as NSError {
                        print(error)
                }
            }
        }
        }.resume()
    }*/
    
    
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

/*extension UIImage {
    func load(image imageName: String) -> UIImage {
        // declare image location
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        // check if the image is stored already
        if FileManager.default.fileExists(atPath: imagePath),
            let imageData: Data = try? Data(contentsOf: imageUrl),
            let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
            return image
        }
        
        // image has not been created yet: create it, store it, return it
        let newImage: UIImage = // create your UIImage here
            try? UIImagePNGRepresentation(newImage)?.write(to: imageUrl)
        return newImage
    }
}*/
