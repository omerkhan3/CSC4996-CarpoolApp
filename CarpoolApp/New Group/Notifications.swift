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
    let Read: Int
    
    init(json: [String: Any]) {
        Date = json["Date"] as? String ?? ""
        Read = json["Read"] as? Int ?? -1
        notificationType = json["notificationType"] as? String ?? ""
    }
}
