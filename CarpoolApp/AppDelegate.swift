//
//  AppDelegate.swift
//  CarpoolApp
//
//  Created by Omer Khan on 1/27/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import IQKeyboardManagerSwift

// Global launch variable
var firstTime = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceToken:String!=""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Check if first time launch
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        // Should be false on first run
        if launchedBefore {
            print("App has launched before")
            firstTime = "notFirstTime"
        } else {
            print("First time launch")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            firstTime = "firstTime"
        }
        
        // Configure firebase
        FirebaseApp.configure()
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound], completionHandler: {(granted, error) in
        })
        application.registerForRemoteNotifications()
        IQKeyboardManager.shared.enable = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("success in registering for remote notifications with token \(deviceTokenString)")
        self.deviceToken = deviceTokenString
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
         print("failed to register for remote notifications: \(error.localizedDescription)")
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Received push notification: \(userInfo)")
        let aps = userInfo["aps"] as! [String: Any]
        print("\(aps)")
    }

 

}

