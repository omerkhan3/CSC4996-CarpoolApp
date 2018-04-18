//
//  UnpaidPayout.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 4/18/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct UnpaidPayout: Decodable{
    let sum: Double
    
    init(json: [String: Any]) {
        sum = json["sum"] as? Double ?? 0.0
    }
    
    init() {
        sum = 0.0
    }
}
