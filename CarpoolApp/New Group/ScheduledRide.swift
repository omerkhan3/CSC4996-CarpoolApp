//
//  ScheduledRide.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/24/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct ScheduledRide: Decodable {
    
    let driverFirstName: String
    let driverStartAddress: String?
    let driverEndAddress: String?
    let driverStartPointLat: Double
    let driverStartPointLong: Double
    let driverEndPointLat: Double
    let driverEndPointLong: Double
    
    let riderFirstName: String
    let riderStartAddress: String?
    let riderEndAddres: String?
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
    let riderPickupTime: String?
    let riderDropoffTime: String?
    let driverLeaveTime: String?
    let riderPickupTime2: String?
    let driverRouteName: String
    let riderRouteName: String

    // JSON constructor
    init(json: [String: Any]) {
        driverFirstName = json["driverFirstName"] as? String ?? "<driver first name>"
        driverStartAddress = json["driverStartAddress"] as? String ?? "<driver start address>"
        driverEndAddress = json["driverEndAddress"] as? String ?? "<driver end address>"
        driverStartPointLat = json["driverStartPointLat"] as? Double ?? 0.0
        driverStartPointLong = json["driverStartPointLong"] as? Double ?? 0.0
        driverEndPointLat = json["driverEndPointLat"] as? Double ?? 0.0
        driverEndPointLong = json["driverEndPointLong"] as? Double ?? 0.0
       
        riderFirstName = json["riderFirstName"] as? String ?? "<rider first name>"
        riderStartAddress = json["riderStartAddress"] as? String ?? "<rider start address>"
        riderEndAddres = json["riderEndAddress"] as? String ?? "<rider end address>"
        riderStartPointLat = json["riderStartPointLat"] as? Double ?? 0.0
        riderStartPointLong = json["riderStartPointLong"] as? Double ?? 0.0
        riderEndPointLat = json["riderEndPointLat"] as? Double ?? 0.0
        riderEndPointLong = json["riderEndPointLong"] as? Double ?? 0.0
        
        matchID = json["matchID"] as? Int ?? 0
        Day = json["Day"] as? String ?? "<day>"
        Date = json["Date"] as? String ?? "<date>"
        driverRouteID = json["driverRouteID"] as? Int ?? 0
        riderRouteID = json["riderRouteID"] as? Int ?? 0
        riderID = json["riderID"] as? String ?? "<riderID>"
        driverID = json["driverID"] as? String ?? "<driverID>"
        riderPickupTime = json["riderPickupTime"] as? String ?? ""
        riderDropoffTime = json["riderDropOffTime"] as? String ?? ""
        driverLeaveTime = json["driverLeaveTime"] as? String ?? ""
        riderPickupTime2 = json["riderPickupTime2"] as? String ?? ""
        riderRouteName = json["riderRouteName"] as? String ?? "<rider route name>"
        driverRouteName = json["driverRouteName"] as? String ?? "<driver route name>"
    }
    
    init() {
        driverFirstName = "<driver first name>"
        driverStartAddress = "<driver start address>"
        driverEndAddress = "<driver end address>"
        driverStartPointLat = 0.0
        driverStartPointLong = 0.0
        driverEndPointLat = 0.0
        driverEndPointLong =  0.0
        
        riderFirstName = "<rider first name>"
        riderStartAddress = "<rider start address>"
        riderEndAddres  = "<rider end address>"
        riderStartPointLat = 0.0
        riderStartPointLong = 0.0
        riderEndPointLat = 0.0
        riderEndPointLong = 0.0
        
        matchID = 0
        Day = "<day>"
        Date = "<date>"
        driverRouteID = 0
        riderRouteID = 0
        riderID = "<riderID>"
        driverID = "<driverID"
        riderPickupTime = ""
        riderDropoffTime = ""
        driverLeaveTime = ""
        riderPickupTime2 = ""
        riderRouteName = "<rider route name"
        driverRouteName = "<driver route name>"
    }
}
