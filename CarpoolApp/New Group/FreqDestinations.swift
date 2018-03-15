//
//  FreqDestinations.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/12/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct Destinations: Decodable {
    let name: String
    let address: String
    //let longitudes: Double
    //let latitudes: Double
    
    init(json: [String: Any]) {
        name = json["Name"] as? String ?? ""
        address = json["Address"] as? String ?? ""
        //longitudes = json["Longitudes"] as? Double ?? 0.0
        //latitudes = json["Latitudes"] as? Double ?? 0.0
    }
}
