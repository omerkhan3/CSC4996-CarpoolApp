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
    
    
    @IBOutlet var notificationsTableView: UITableView!
    
    // array of notifications
    var notificationsArray = [Notifications]()
    
    
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
        
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Notification Type
        let type = notificationsArray[indexPath.row].notificationType
        print(type)
        
        // Segue to matches view if notifications is type: "Match"
        if (type == "Match") {
            self.performSegue(withIdentifier: "showMatches1", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "notificationCell")
        
        
        
        // set title to notification type
        cell.textLabel?.text = "You have a new " + notificationsArray[indexPath.row].notificationType
        //cell.detailTextLabel?.text = "\(formatDate(date: notificationsArray[indexPath.row].Date))"
        cell.detailTextLabel?.text = notificationsArray[indexPath.row].Date

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
            notificationsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // Download notifications JSON and decode into an array
    func getNotifications(completed: @escaping () -> ()) {
        // get userID
        let userID = Auth.auth().currentUser?.uid
        var viewNotificationComponents = URLComponents(string: "http://localhost:3000/notifications")!
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
    
    func formatDate(date: String) -> String {
        // Create date formatter and reformat date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        print(date)
        let formattedDate = dateFormatter.date(from: date)!
        dateFormatter.dateFormat = "MM-dd-YYYY"
        let dateString = dateFormatter.string(from: formattedDate)
        
        return dateString
    }
}
