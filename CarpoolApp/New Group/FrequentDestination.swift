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
    let frequentDestinationID: Int
    
    // JSON constructor
    init(json: [String: Any]) {
        Name = json["Name"] as? String ?? ""
        Address = json["Address"] as? String ?? ""
        frequentDestinationID = json["frequentDestinationID"] as? Int ?? -1
    }
    
    init(){
        Name = ""
        Address = ""
        frequentDestinationID = -1
    }
}
