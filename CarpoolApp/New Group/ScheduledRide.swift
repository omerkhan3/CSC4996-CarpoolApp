//
//  ScheduledRide.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/24/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct ScheduledRide: Decodable {
    
    let driverStartPointLat: Double
    let driverStartPointLong: Double
    let driverEndPointLat: Double
    let driverEndPointLong: Double
    let riderStartPointLat: Double
    let riderStartPointLong: Double
    let riderEndPointLat: Double
    let riderEndPointLong: Double
    let matchID: Int
    let Day: String
    let Date: String
    let driverRouteID: Int
    let riderRouteID: Int
    let riderID: String
    let driverID: String
// let riderPickupTime: Int
// let riderDropoffTime: Int
// let driverLeaveTime: Int
// let riderPickupTime2:
    let driverRouteName: String
    let riderRouteName: String

    // JSON constructor
    init(json: [String: Any]) {
        driverStartPointLat = json["driverStartPointLat"] as? Double ?? 0.0
        driverStartPointLong = json["driverStartPointLong"] as? Double ?? 0.0
        driverEndPointLat = json["driverEndPointLat"] as? Double ?? 0.0
        driverEndPointLong = json["driverEndPointLong"] as? Double ?? 0.0
        riderStartPointLat = json["riderStartPointLat"] as? Double ?? 0.0
        riderStartPointLong = json["riderStartPointLong"] as? Double ?? 0.0
        riderEndPointLat = json["riderEndPointLat"] as? Double ?? 0.0
        riderEndPointLong = json["riderEndPointLong"] as? Double ?? 0.0
        matchID = json["matchID"] as? Int ?? 0
        Day = json["Day"] as? String ?? ""
        Date = json["Date"] as? String ?? ""
        driverRouteID = json["driverRouteID"] as? Int ?? 0
        riderRouteID = json["riderRouteID"] as? Int ?? 0
        riderID = json["riderID"] as? String ?? ""
        driverID = json["driverID"] as? String ?? ""
        // riderPickupTime = json["riderPickupTime"] as? Int ?? 0
        // riderDropoffTime = json["riderDropoffTime"] as? Int ?? 0
        // driverLeaveTime = json["driverLeaveTime"] as? Int ?? 0
        // riderPickupTime2 = json["riderPickupTime2"] as? Int ?? 0
        riderRouteName = json["riderRouteName"] as? String ?? ""
        driverRouteName = json["driverRouteName"] as? String ?? ""
    }
    
    init() {
        driverStartPointLat = 0.0
        driverStartPointLong = 0.0
        driverEndPointLat = 0.0
        driverEndPointLong =  0.0
        riderStartPointLat = 0.0
        riderStartPointLong = 0.0
        riderEndPointLat = 0.0
        riderEndPointLong = 0.0
        matchID = 0
        Day = ""
        Date = ""
        driverRouteID = 0
        riderRouteID = 0
        riderID = ""
        driverID = ""
        // riderPickupTime = 0
        // riderDropoffTime = 0
        // driverLeaveTime = 0
        // riderPickupTime2 = 0
        riderRouteName = ""
        driverRouteName = ""
    }
}
