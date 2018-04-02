//
//  SideMenuTableViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/3/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Foundation
import SideMenu

class SideMenuTableViewController: UITableViewController {
    
    @IBOutlet var userMenuTableView: UITableView!
    let menuOptions = ["User Profile", "Matches", "My Routes", "Payments", "Settings", "Help", "Logout"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh cell blur effect
        tableView.reloadData()
        
        guard SideMenuManager.default.menuBlurEffectStyle == nil else {
            return
        }
        
        // set background image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userMenuTableView.delegate = self
        userMenuTableView.dataSource = self
        userMenuTableView.accessibilityIdentifier = "sideMenuTableView"
        

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell
        let cell = userMenuTableView.dequeueReusableCell(withIdentifier: "menuCell")
        
        cell?.textLabel?.text = menuOptions[indexPath.row]
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    // assign segues to tableView rows
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
        self.performSegue(withIdentifier: "showProfile", sender: self)
        }
        
        else if indexPath.row == 1
        {
            self.performSegue(withIdentifier: "showMatches", sender: self)
        }
        
        else if indexPath.row == 2
        {
            self.performSegue(withIdentifier: "showRoutes", sender: self)
        }
            
        else if indexPath.row == 3
        {
            self.performSegue(withIdentifier: "showPayments", sender: self)
        }
        
        else if indexPath.row == 4
        {
            self.performSegue(withIdentifier: "showSettings", sender: self)
        }
        
        else if indexPath.row == 5
        {
            self.performSegue(withIdentifier: "showHelp", sender: self)
       }
        
        else if indexPath.row == 6
        {
            let logoutAlert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
            logoutAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.performSegue(withIdentifier: "showLogout", sender: self)
            }))
            
            logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(logoutAlert, animated: true)
        }
    }

}
