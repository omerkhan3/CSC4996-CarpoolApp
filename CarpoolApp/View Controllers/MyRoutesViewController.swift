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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userID = Auth.auth().currentUser?.uid
        readMyRoutes(userID: userID!)
        // Do any additional setup after loading the view.
    }
    
    func readMyRoutes(userID: String)
    {
        var viewProfileComponents = URLComponents(string: "http://localhost/frequentDestinations/")!
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
