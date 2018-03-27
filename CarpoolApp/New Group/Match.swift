//
//  Match.swift
//  CarpoolApp
//
//  Created by Evan Clifford on 3/5/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation

struct Match: Decodable{
    
    // driver info
    let driverFirstName: String
    //let driverLastName: String
    let driverBiography: String? // biography is optional
    let driverID: String
    let driverStartPointLat: Double
    let driverStartPointLong: Double
    let driverEndPointLat: Double
    let driverEndPointLong: Double
    let driverRouteUserID: String
    let driverDays: [String]
    let driverArrival: String
    let driverDeparture: String
    let driverRouteName: String
    let driverRouteID: Int?
    
    
    // rider info
    let riderFirstName:String
    //let riderLastName:String
    let riderBiography: String?
    let riderID: String
    let riderStartPointLat: Double
    let riderStartPointLong: Double
    let riderEndPointLat: Double
    let riderEndPointLong: Double
    let riderRouteUserID: String
    let riderDays: [String]
    let riderArrival: String
    let riderDeparture: String
    let riderRouteName: String
    let riderRouteID: Int?
    let riderStartAddress: String
    let riderPickupTime: String
    let driverLeaveTime: String
    let rideCost: Double
    
    // match info
    let Status: String
    let matchID: Int
    
    // JSON Constructor
    init(json: [String: Any]) {
        // driver info
        driverFirstName = json["driverFirstName"] as? String ?? ""
        //driverLastName = json["driverLastName"] as? String ?? ""
        driverBiography = json["driverBiography"] as? String ?? ""
        driverID = json["driverID"] as? String ?? ""
        driverStartPointLat = json["driverStartPointLat"] as? Double ?? 0.0
        driverStartPointLong = json["driverStartPointLong"] as? Double ?? 0.0
        driverEndPointLat = json["driverEndPointLat"] as? Double ?? 0.0
        driverEndPointLong = json["driverEndPointLong"] as? Double ?? 0.0
        driverRouteUserID = json["driverRouteUserID"] as? String ?? ""
        driverDays = json["driverDays"] as? [String] ?? [""]
        driverArrival = json["driverArrival"] as? String ?? ""
        driverDeparture = json["driverDeparture"] as? String ?? ""
        driverRouteName = json["driverRouteName"] as? String ?? ""
        driverRouteID = json["driverRouteID"] as? Int ?? 0
        
        //rider info
        riderFirstName = json["riderFirstName"] as? String ?? ""
        riderBiography = json["riderBiography"] as? String ?? ""
        riderID = json["riderID"] as? String ?? ""
        riderStartPointLat = json["riderStartPointLat"] as? Double ?? 0.0
        riderStartPointLong = json["riderStartPointLong"] as? Double ?? 0.0
        riderEndPointLat = json["riderEndPointLat"] as? Double ?? 0.0
        riderEndPointLong = json["riderEndPointLong"] as? Double ?? 0.0
        riderRouteUserID = json["riderRouteUserID"] as? String ?? ""
        riderDays = json["riderDays"] as? [String] ?? [""]
        riderArrival = json["riderArrival"] as? String ?? ""
        riderDeparture = json["riderDeparture"] as? String ?? ""
        riderRouteName = json["riderRouteName"] as? String ?? ""
        riderRouteID = json["riderRouteID"] as? Int ?? 0
        
        // match info
        Status = json["Status"] as? String ?? ""
        matchID = json["matchID"] as? Int ?? 0
        riderStartAddress = json["riderStartAddress"] as? String ?? ""
        riderPickupTime = json["riderPickupTime"] as? String ?? ""
        driverLeaveTime = json["driverLeaveTime"] as? String ?? ""
        rideCost = json["rideCost"] as? Double ?? 0.0
    }
    
    init(){
        // driver info
        driverFirstName =  ""
        //driverLastName =  ""
        driverBiography = ""
        driverID =  ""
        driverStartPointLat = 0.0
        driverStartPointLong = 0.0
        driverEndPointLat = 0.0
        driverEndPointLong =  0.0
        driverRouteUserID =  ""
        driverDays = [""]
        driverArrival =  ""
        driverDeparture =  ""
        driverRouteName =  ""
        driverRouteID =  0
        
        // rider info
        riderFirstName = ""
        riderBiography = ""
        riderID =  ""
        riderStartPointLat = 0.0
        riderStartPointLong = 0.0
        riderEndPointLat = 0.0
        riderEndPointLong = 0.0
        riderRouteUserID = ""
        riderDays = [""]
        riderArrival = ""
        riderDeparture = ""
        riderRouteName = ""
        riderRouteID = 0
        
        // match info
        Status = ""
        matchID =  0
        riderStartAddress = ""
        riderPickupTime = ""
        driverLeaveTime = ""
        rideCost = 0.0
    }
}
