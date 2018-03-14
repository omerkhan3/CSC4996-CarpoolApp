//
//  FreqDestinations.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/12/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct Destinations: Codable {
    let homeAddress: String
    let schoolAddress: String
    let workAddress: String
    let CustomAddress: String
    let Custom: String
    let longitudes: Double
    let latitudes: Double
    
    /*func getString() -> String {
        return "Home: \(home), School: \(school), Work: \(work), Longitudes: \(longitudes), Latitudes: \(latitudes)"
    }*/
    
    init(json: [String: Any]) {
        homeAddress = json["homeAddress"] as? String ?? ""
        schoolAddress = json["schoolAddress"] as? String ?? ""
        workAddress = json["workAddress"] as? String ?? ""
        CustomAddress = json["CustomAddress"] as? String ?? ""
        Custom = json["Custom"] as? String ?? ""
        longitudes = json["Longitudes"] as? Double ?? 0.0
        latitudes = json["Latitudes"] as? Double ?? 0.0
    }
    
    /*init() {
        home = ""
        school = ""
        work = ""
        longitudes = 0.0
        latitudes = 0.0
    }*/
}
