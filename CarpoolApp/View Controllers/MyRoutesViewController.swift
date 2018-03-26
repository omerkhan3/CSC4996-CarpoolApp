//
//  MyRoutesViewController.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/7/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MyRoutesViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var UserHomeAddress: UILabel!
    @IBOutlet weak var UserSchoolAddress: UILabel!
    @IBOutlet weak var UserWorkAddress: UILabel!
    @IBOutlet weak var UserOtherAddress: UILabel!
    @IBOutlet weak var otherDestination: UILabel!
    @IBAction func editButton(_ sender: Any) {
    }
    @IBOutlet weak var newLabel: UILabel!
    @IBAction func addRoute(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        getDestinations(userID: userID!)
        UserHomeAddress.isHidden = true
        UserSchoolAddress.isHidden = true
        UserWorkAddress.isHidden = true
        UserOtherAddress.isHidden = true
    }
    
    func getDestinations(userID: String) {
        var viewDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/getDestination")!
        viewDestinationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewDestinationComponents.url!)  // Pass Parameter in URL
        print (viewDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                print(data)
                let destinationInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = destinationInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String:AnyObject]]
                        print (json as Any)
                        for data in json
                        {
                            if (data["Name"] as! String == "Home")
                            {
                                self.UserHomeAddress.isHidden = false
                                DispatchQueue.main.async
                                {
                                        self.UserHomeAddress.text = (data["Address"] as? String)
                                }
                            }
                            else if (data["Name"] as! String == "School")
                            {
                                self.UserSchoolAddress.isHidden = false
                                DispatchQueue.main.async
                                {
                                        self.UserSchoolAddress.text = (data["Address"] as? String)
                                }
                            }
                            else if (data["Name"] as! String == "Work")
                            {
                                self.UserWorkAddress.isHidden = false
                                DispatchQueue.main.async
                                {
                                        self.UserWorkAddress.text = (data["Address"] as? String)
                                }
                            }
                            else
                            {
                                self.UserOtherAddress.isHidden = false
                                DispatchQueue.main.async
                                {
                                        self.otherDestination.text = (data["Name"] as? String)
                                        self.UserOtherAddress.text = (data["Address"] as? String)
                                }
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
}
