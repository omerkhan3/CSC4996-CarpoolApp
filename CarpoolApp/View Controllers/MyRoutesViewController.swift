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
    @IBAction func editButton(_ sender: Any) {
    }
    @IBOutlet weak var newLabel: UILabel!
    @IBAction func addRoute(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        readMyDestinations(userID: userID!)
    }
    
    func readMyDestinations(userID: String)
    {
        var viewDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/frequentDestinations")!
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
                let routeInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = routeInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        print (json as Any)
                        if let routeInfo = json!["data"]
                        {
                            DispatchQueue.main.async {
                               self.UserHomeAddress.text = (routeInfo["Address"] as! String)
                               self.UserSchoolAddress.text = (routeInfo["schoolAddress"] as? String)
                               self.UserWorkAddress.text = (routeInfo["workAddress"] as? String)
                               self.UserOtherAddress.text = (routeInfo["otherAddress"] as? String)
                               self.newLabel.text = (routeInfo["Name5"] as? String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    //Decoding frequent destinations
    /*func readMyDestinations(completed: @escaping () -> ()) {
        let userID = Auth.auth().currentUser?.uid
        var viewDestinationComponents = URLComponents(string: "http://localhost:3000/frequentDestinations")!
        viewDestinationComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewDestinationComponents.url!)  // Pass Parameter in URL
        print (viewDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
        if (error != nil){  // error handling responses.
            print (error as Any)
        } else {
            guard let data = data else {return}
            do {
                self.destinationsArray = try JSONDecoder().decode([Destinations].self, from: data)
                print(self.destinationsArray)
                DispatchQueue.main.async {
                    self.homeAddress.text = (routeInfo["homeAddress"] as! String)
                    self.schoolAddress.text = (routeInfo["schoolAddress"] as! String)
                    self.workAddress.text = (routeInfo["workAddress"] as! String)
                    completed()
                    }
                }catch let jsnErr {
                print(jsnErr)
                }
            }
        }.resume()
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
