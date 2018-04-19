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


class NotificationsTableViewController: UITableViewController {
    
    // array of notifications
    var notificationsArray = [Notifications]()
    
    @IBOutlet var notificationsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh cell blur effect
        tableView.reloadData()
        
        guard SideMenuManager.default.menuBlurEffectStyle == nil else {
            return
        }
        
        getNotifications {
            self.tableView.reloadData()
            if self.notificationsArray.count == 0 {
                // No notifications alert
                let actionTitle = "Uh oh.."
                let actionItem = "You have no notifications!"
                
                // Activate UIAlertController to display confirmation
                let alert = UIAlertController(title: actionTitle, message: actionItem, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
  
        
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Notification Type
        let type = notificationsArray[indexPath.row].notificationType
        print(type)
        
        // Segue to matches view if notifications is type: "Match"
        if (type == "You have a new match!") {
            self.performSegue(withIdentifier: "showMatches1", sender: self)
        }
        if (type == "You have a new ride request!") {
            self.performSegue(withIdentifier: "showMatches1", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationTableViewCell
        
        // set title to notification type
        cell.notificationLbl.text = notificationsArray[indexPath.row].notificationType
        cell.notificationDateLbl.text = formatDate(date: notificationsArray[indexPath.row].Date)

        return cell
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsArray.count
    }
    
    //Deleting functionality
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notificationID = notificationsArray[indexPath.row].notificationID
            notificationsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            let deletingNotification = ["notificationID" : notificationID]
            self.deleteNotification(deletingNotification: deletingNotification)
        }
    }

    // Download notifications JSON and decode into an array
    func getNotifications(completed: @escaping () -> ()) {
        // get userID
        let userID = Auth.auth().currentUser?.uid
        var viewNotificationComponents = URLComponents(string: "http://141.217.48.208:3000/notifications")!
        viewNotificationComponents.queryItems = [URLQueryItem(name: "userID", value: userID)]
        var request = URLRequest(url: viewNotificationComponents.url!)  // Pass Parameter in URL
        print (viewNotificationComponents.url!)
        
        request.httpMethod = "GET" // GET METHOD
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if (error != nil){  // error handling responses.
                print (error as Any)
            } else {
                    guard let data = data else { return }
                do {
                    // decode JSON into Notifications[] array type
                    self.notificationsArray = try JSONDecoder().decode([Notifications].self, from: data)
                    print(self.notificationsArray)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch let jsnErr {
                    print(jsnErr)
                }
            }
        }.resume()
    }
    
    func deleteNotification(deletingNotification: Dictionary<String, Any>)
    {
        let deleteNotificationURL = URL(string: "http://141.217.48.208:3000/notifications/deleteIndividual")!
        var request = URLRequest(url: deleteNotificationURL)
        let deleteNotificationJSON = try! JSONSerialization.data(withJSONObject: deletingNotification, options: .prettyPrinted)
        let deletingNotificationJSONInfo = NSString(data: deleteNotificationJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "deletingNotification=\(deletingNotificationJSONInfo)".data(using: String.Encoding.utf8)
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
    
    func formatDate(date: String) -> String {
        // Create date formatter and reformat date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        print(date)
        let formattedDate = dateFormatter.date(from: date)!
        dateFormatter.dateFormat = "MM-dd-YYYY h:mm a"
        let dateString = dateFormatter.string(from: formattedDate)
        
        return dateString
    }
}
