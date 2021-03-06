//
//  SavedRoutes.swift
//  CarpoolApp
//
//  Created by Matt Prigorac on 4/7/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct SavedRoutes: Decodable {
    let Name: String
    let endAddress: String
    let routeID : Int
    let Matched: Bool
    
    init(json: [String: Any]) {
        Name = json["Name"] as? String ?? ""
        endAddress = json["endAddress"] as? String ?? ""
        routeID = json["routeID"] as? Int ?? 0
        Matched = json["Matched"] as? Bool ?? false
    }
    
    init() {
        Name =  ""
        endAddress = ""
        routeID = 0
        Matched = false
    }
}
