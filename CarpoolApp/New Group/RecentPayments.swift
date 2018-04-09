//
//  RecentPayments.swift
//  CarpoolApp
//
//  Created by muamer besic on 3/28/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct RecentPayments: Decodable {
    let driverFirstName: String
    let Time: String
    let Amount: Double
    
    init(json: [String: Any]) {
        driverFirstName = json["driverFirstName"] as? String ?? ""
        Time = json["Time"] as? String ?? ""
        Amount = json["Amount"] as? Double ?? 0.0
    }
    
    init() {
        driverFirstName = ""
        Time = ""
        Amount = 0.0
    }
}
