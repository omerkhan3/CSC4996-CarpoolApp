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
   // let driverRouteUserID: String
    let driverDays: [String]
//    let driverArrival1: String
//    let driverArrival2: String
//    let driverDeparture1: String
    let driverDeparture2: String
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
   // let riderRouteUserID: String
    let riderDays: [String]
//  //  let riderArrival1: String
//   // let riderArrival2: String
//    //let riderDeparture1: String
//    let riderDeparture2: String
    let riderRouteName: String
    let riderRouteID: Int?
    let riderStartAddress: String
    let riderEndAddress: String
    let riderPickupTime: String
    let riderDropOffTime: String
    let riderPickupTime2: String
    let driverLeaveTime: String
    // let driverLeaveTime2: String
    let rideCost: Double
    
    // match info
    let Status: String
    let matchID: Int
    let matchedDays: [String]
    
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
      //  driverRouteUserID = json["driverRouteUserID"] as? String ?? ""
        driverDays = json["driverDays"] as? [String] ?? [""]
//        driverArrival1 = json["driverArrival1"] as? String ?? ""
//        driverArrival2 = json["driverArrival2"] as? String ?? ""
//        driverDeparture1 = json["driverDeparture1"] as? String ?? ""
        driverDeparture2 = json["driverDeparture2"] as? String ?? ""
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
     //   riderRouteUserID = json["riderRouteUserID"] as? String ?? ""
        riderDays = json["riderDays"] as? [String] ?? [""]
//        riderArrival1 = json["riderArrival1"] as? String ?? ""
//        riderArrival2 = json["riderArrival2"] as? String ?? ""
//        riderDeparture1 = json["riderDeparture1"] as? String ?? ""
//        riderDeparture2 = json["riderDeparture2"] as? String ?? ""
        riderRouteName = json["riderRouteName"] as? String ?? ""
        riderRouteID = json["riderRouteID"] as? Int ?? 0
        
        // match info
        Status = json["Status"] as? String ?? ""
        matchID = json["matchID"] as? Int ?? 0
        riderStartAddress = json["riderStartAddress"] as? String ?? ""
        riderEndAddress = json["riderEndAddress"] as? String ?? ""
        riderPickupTime = json["riderPickupTime"] as? String ?? ""
        riderDropOffTime = json["riderDropOffTime"] as? String ?? ""
        driverLeaveTime = json["driverLeaveTime"] as? String ?? ""
        riderPickupTime2 = json["riderPickupTime2"] as? String ?? ""
        rideCost = json["rideCost"] as? Double ?? 0.0
        matchedDays = json["matchedDays"] as? [String] ?? [""]
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
       // driverRouteUserID =  ""
        driverDays = [""]
//        driverArrival1 =  ""
//        driverArrival2 =  ""
        //driverDeparture1 =  ""
        driverDeparture2 =  ""
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
      //  riderRouteUserID = ""
        riderDays = [""]
//        riderArrival1 = ""
//        riderArrival2 = ""
//        riderDeparture1 = ""
//        riderDeparture2 = ""
        riderRouteName = ""
        riderRouteID = 0
        
        // match info
        Status = ""
        matchID =  0
        matchedDays = [""]
        riderStartAddress = ""
        riderEndAddress = ""
        riderPickupTime = ""
        riderDropOffTime = ""
        driverLeaveTime = ""
        riderPickupTime2 = ""
        rideCost = 0.0
    }
}
