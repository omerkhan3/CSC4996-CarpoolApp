//
//  DashboardViewController.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/3/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import SideMenu
import FirebaseAuth

class DashboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
       registerDeviceToken()
    }
    
    func registerDeviceToken()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //print("Device Token:", appDelegate.deviceToken)
        if ((appDelegate.deviceToken?.isEmpty)!)
        {
            print ("Device already registered.")
        }
        else
        {
            let userInfo = ["userID": Auth.auth().currentUser?.uid as Any,   "deviceToken" : appDelegate.deviceToken] as [String:Any]
            updateDevice(userInfo : userInfo)
        }
        
    }
    
    
    func updateDevice(userInfo: Dictionary<String, Any>)
    {
        let editDeviceURL = URL(string: "http://141.217.48.15:3000/users/device")!
        var request = URLRequest(url: editDeviceURL)
        let userJSON = try! JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        let userJSONInfo = NSString(data: userJSON, encoding: String.Encoding.utf8.rawValue)! as String
        request.httpBody = "userInfo=\(userJSONInfo)".data(using: String.Encoding.utf8)
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

    fileprivate func setupSideMenu() {
        // Define the menus
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "UserMenuNavigationController") as? UISideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        // Set up a cool background image for demo purposes
        //SideMenuManager.default.menuAnimationBackgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
}
    
extension DashboardViewController: UISideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
        
}

