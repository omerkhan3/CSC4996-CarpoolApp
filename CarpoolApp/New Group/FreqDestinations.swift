//
//  FreqDestinations.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/12/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct Destinations: Codable {
    let home: String
    let school: String
    let work: String
    let longitudes: Double
    let latitudes: Double
    
    /*func getString() -> String {
        return "Home: \(home), School: \(school), Work: \(work), Longitudes: \(longitudes), Latitudes: \(latitudes)"
    }*/
    
    init(json: [String: Any]) {
        home = json["homeAddress"] as? String ?? ""
        school = json["schoolAddress"] as? String ?? ""
        work = json["workAddress"] as? String ?? ""
        longitudes = json["Longitudes"] as? Double ?? 0.0
        latitudes = json["Latitudes"] as? Double ?? 0.0
    }
    
    init() {
        home = ""
        school = ""
        work = ""
        longitudes = 0.0
        latitudes = 0.0
    }
}
