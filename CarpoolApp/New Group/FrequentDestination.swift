//
//  FrequentDestination.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/28/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct FrequentDestination: Decodable {
    
    let Name: String
    let Address: String
    let DestinationID: Int
    
    // JSON constructor
    init(json: [String: Any]) {
        Name = json["Name"] as? String ?? ""
        Address = json["Address"] as? String ?? ""
        DestinationID = json["frequentDestinationID"] as? Int ?? -1
    }
    
    init(){
        Name = ""
        Address = ""
        DestinationID = -1
    }
}
