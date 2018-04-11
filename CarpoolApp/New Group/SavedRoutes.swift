//
//  SavedRoutes.swift
//  CarpoolApp
//
//  Created by muamer besic on 4/7/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct SavedRoutes: Decodable {
    let Name: String
    let endAddress: String
    let routeID : Int
    
    init(json: [String: Any]) {
        Name = json["Name"] as? String ?? ""
        endAddress = json["endAddress"] as? String ?? ""
        routeID = json["routeID"] as? Int ?? 0
    }
    
    init() {
        Name =  ""
        endAddress = ""
        routeID = 0
    }
}
