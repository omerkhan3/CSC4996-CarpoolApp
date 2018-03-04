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
    let menuOptions = ["User Profile", "Notifications", "Matches", "My Routes", "Settings", "Help", "Logout"]
    
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
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell
        let cell = userMenuTableView.dequeueReusableCell(withIdentifier: "menuCell")
        
        //cell.blurEffectStyle = SideMenuManager.default.menuBlurEffectStyle
        
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
            self.performSegue(withIdentifier: "showNotifications", sender: self)
        }
        
//        else if indexPath.row == 2
//        {
//            self.performSegue(withIdentifier: "showMatches", sender: self)
//        }
        
        else if indexPath.row == 3
        {
            self.performSegue(withIdentifier: "showRoutes", sender: self)
        }
        
//        else if indexPath.row == 4
//        {
//            self.performSegue(withIdentifier: "showSettings", sender: self)
//        }
        
//        else if indexPath.row == 5
//        {
//            self.performSegue(withIdentifier: "showHelp", sender: self)
//        }
        
        else if indexPath.row == 6
        {
            self.performSegue(withIdentifier: "showLogout", sender: self)
        }
    }

}