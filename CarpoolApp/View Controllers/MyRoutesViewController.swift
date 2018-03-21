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
        readMyHomeDestinations(userID: userID!)
        readMySchoolDestinations(userID: userID!)
        readMyWorkDestinations(userID: userID!)
        readMyCustomDestinations(userID: userID!)
    }
    
    func readMyHomeDestinations(userID: String)
    {
        var viewHomeDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/homeDestination")!
        viewHomeDestinationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewHomeDestinationComponents.url!)  // Pass Parameter in URL
        print (viewHomeDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                print(data)
                let homeInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = homeInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        print (json as Any)
                        if let homeInfo = json!["data"]
                        {
                            DispatchQueue.main.async {
                                self.UserHomeAddress.text = (homeInfo["Address"] as! String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    func readMySchoolDestinations(userID: String)
    {
        var viewSchoolDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/schoolDestination")!
        viewSchoolDestinationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewSchoolDestinationComponents.url!)  // Pass Parameter in URL
        print (viewSchoolDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                print(data)
                let schoolInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = schoolInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        print (json as Any)
                        if let schoolInfo = json!["data"]
                        {
                            DispatchQueue.main.async {
                                self.UserSchoolAddress.text = (schoolInfo["Address"] as! String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    func readMyWorkDestinations(userID: String)
    {
        var viewWorkDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/workDestination")!
        viewWorkDestinationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewWorkDestinationComponents.url!)  // Pass Parameter in URL
        print (viewWorkDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                print(data)
                let workInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = workInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        print (json as Any)
                        if let workInfo = json!["data"]
                        {
                            DispatchQueue.main.async {
                                self.UserWorkAddress.text = (workInfo["Address"] as! String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }
    
    func readMyCustomDestinations(userID: String)
    {
        var viewCustomDestinationComponents = URLComponents(string: "http://localhost:3000/freqDestinations/customDestination")!
        viewCustomDestinationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewCustomDestinationComponents.url!)  // Pass Parameter in URL
        print (viewCustomDestinationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            }
            else if let data = data {
                print(data)
                let customInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = customInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        print (json as Any)
                        if let customInfo = json!["data"]
                        {
                            DispatchQueue.main.async {
                                self.UserOtherAddress.text = (customInfo["Address"] as! String)
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
