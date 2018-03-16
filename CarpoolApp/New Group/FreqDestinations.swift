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
    let name2: String
    let name3: String
    let name4: String
    let name5: String
    let address: String
    let schooladdress: String
    let workaddress: String
    let otheraddress: String
    let longitudes: Double
    let latitudes: Double
    
    init(json: [String: Any]) {
        name = json["Name"] as? String ?? ""
        name2 = json["Name2"] as? String ?? ""
        name3 = json["Name3"] as? String ?? ""
        name4 = json["Name4"] as? String ?? ""
        name5 = json["Name5"] as? String ?? ""
        address = json["Address"] as? String ?? ""
        schooladdress = json["schoolAddress"] as? String ?? ""
        workaddress = json["workAddress"] as? String ?? ""
        otheraddress = json["otherAddress"] as? String ?? ""
        longitudes = json["Longitudes"] as? Double ?? 0.0
        latitudes = json["Latitudes"] as? Double ?? 0.0
    }
}
