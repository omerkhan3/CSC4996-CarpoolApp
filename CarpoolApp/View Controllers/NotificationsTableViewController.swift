//
//  NotificationsTableViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/3/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import SideMenu
import Firebase
import FirebaseAuth


struct NotificationObject {
    let notificationType: String?
    let Date: String?
    let Read: Bool?
}

class NotificationsTableViewController: UITableViewController {
    
    
    @IBOutlet var notificationsTableView: UITableView!
    
    // array of notifications
    var notificationsArray = [NotificationObject]()
    var notificationData = [[String : AnyObject]]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh cell blur effect
        tableView.reloadData()
        
        guard SideMenuManager.default.menuBlurEffectStyle == nil else {
            return
        }
        
        // --set background image--
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get userID
        let userID = Auth.auth().currentUser?.uid
        getNotifications(userID: userID!)
        // download notifications
//        readNotificationInfo(userID: userID!) {
//            self.tableView.reloadData()
//        }
        
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
            // set title to notification type
            cell.textLabel?.text = notificationsArray[indexPath.row].notificationType
            return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsArray.count
    }
    
    func getNotifications(userID: String){
        
        var viewNotificationComponents = URLComponents(string: "http://localhost:3000/notifications")!
        viewNotificationComponents.queryItems = [
            URLQueryItem(name: "userID", value: userID)
        ]
        var request = URLRequest(url: viewNotificationComponents.url!)  // Pass Parameter in URL
        print (viewNotificationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            } else if let data = data {
                print(data)
                let userInfoString:NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                if let data = userInfoString.data(using: String.Encoding.utf8.rawValue) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                        print (json as Any)
                    } catch let error as NSError {
                        print (error)
                    }
                }
            }
        }.resume()
    }
    
}

