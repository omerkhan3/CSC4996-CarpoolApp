//
//  FreqDestinations.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/12/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct Destinations: Decodable {
    let home: String
    let school: String
    let work: String
    let customAddress: String
    let custom: String
    let longitudes: Double
    let latitudes: Double
    
    init(json: [String: Any]) {
        home = json["homeAddress"] as? String ?? ""
        school = json["schoolAddress"] as? String ?? ""
        work = json["workAddress"] as? String ?? ""
        customAddress = json["CustomAddress"] as? String ?? ""
        custom = json["Custom"] as? String ?? ""
        longitudes = json["Longitudes"] as? Double ?? 0.0
        latitudes = json["Latitudes"] as? Double ?? 0.0
    }
}
