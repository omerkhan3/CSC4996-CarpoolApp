//
//  Notifications.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/4/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//
import Foundation

struct Notifications: Decodable{
    let notificationType: String
    let Date: String
    let Read: Bool
    let notificationID: Int
    
    init(json: [String: Any]) {
        Date = json["Date"] as? String ?? ""
        Read = json["Read"] as? Bool ?? false
        notificationType = json["notificationType"] as? String ?? ""
        notificationID = json["notificationID"] as? Int ?? -1
     }
    
    init() {
        Date = ""
        notificationType = ""
        Read = false
        notificationID = -1
    }
}
