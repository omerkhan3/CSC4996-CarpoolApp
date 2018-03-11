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
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var homeAddress: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var schoolAddress: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var workAddress: UILabel!
    @IBAction func editButton(_ sender: Any) {
    }
    @IBAction func addRoute(_ sender: Any) {
    }
    
    var myRoutes = [Destinations]()
    struct Destinations: Decodable {
        let homeAddress: String
        let schoolAddress: String
        let workAddress: String
        
        init(json: [String: Any]) {
            homeAddress = json["homeAddress"] as? String ?? ""
            schoolAddress = json["schoolAddress"] as? String ?? ""
            workAddress = json["workAddress"] as? String ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        //readMyDestinations(userID: userID!)
        // Do any additional setup after loading the view.
    }
    
    /*func readMyDestinations(userID: String)
    {
        var viewDestinationComponents = URLComponents(string: "http://localhost:3000/frequentDestinations")!
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
                               self.homeAddress.text = (routeInfo["homeAddress"] as! String)
                               self.schoolAddress.text = (routeInfo["schoolAddress"] as! String)
                               self.workAddress.text = (routeInfo["workAddress"] as! String)
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            }.resume()
    }*/
    
    //Decoding frequent destinations
    func readMyDestinations(completed: @escaping () -> ()) {
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
                self.myRoutes = try JSONDecoder().decode([Destinations].self, from: data)
                print(self.myRoutes)
                DispatchQueue.main.async {
                    self.homeAddress.text = self.myRoutes[0].homeAddress
                    self.schoolAddress.text = self.myRoutes[0].schoolAddress
                    self.workAddress.text = self.myRoutes[0].workAddress
                    completed()
                    }
                }catch let jsnErr {
                print(jsnErr)
                }
            }
        }.resume()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
