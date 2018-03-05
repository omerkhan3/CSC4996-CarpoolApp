//
//  Match.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/5/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct Match: Decodable{
    let driverFirstName: String
    let driverLastName: String
    let driverBiography: String? // biography is optional
    let driverID: Int
    let driverEndPointLat: Double
    let driverEndPointLong: Double
    let driverRouteUserID: Int
    let driverArrival: String
    let driverDeparture: String
    let driverRouteName: String
    let driverRouteID: Int
    let matchID: Int
    let riderID: Int
    
    // Constructor
    init(json: [String: Any]) {
        driverFirstName = json["driverFirstName"] as? String ?? ""
        driverLastName = json["driverLastName"] as? String ?? ""
        driverBiography = json["driverBiography"] as? String ?? ""
        driverID = json["driverID"] as? Int ?? -1
        driverEndPointLat = json["driverEndPointLat"] as? Double ?? 0.0
        driverEndPointLong = json["driverEndPointLong"] as? Double ?? 0.0
        driverRouteUserID = json["driverRouteUserID"] as? Int ?? -1
        driverArrival = json["driverArrival"] as? String ?? ""
        driverDeparture = json["driverDeparture"] as? String ?? ""
        driverRouteName = json["driverRouteName"] as? String ?? ""
        driverRouteID = json["driverRouteID"] as? Int ?? -1
        matchID = json["matchID"] as? Int ?? -1
        riderID = json["riderID"] as? Int ?? -1
    }
}
