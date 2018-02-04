//
//  otherlocations.swift
//  CarpoolApp
//
//  Created by Matt on 2/3/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//
import Geofire
import Foundation
import MapKit
import AddressBook
import Firebase
//import SwiftyJSON




let geofireRef = FIRDatabase.database().reference()
let geoFire = GeoFire(firebaseRef: geofireRef)


let center = CLLocation(latitude: self, longitude: self)

//Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
var circleQuery = geoFire.queryAtLocation(center, withRadius: 0.6)

// Query location by region
let span = MKCoordinateSpanMake(0.001, 0.001)
let region = MKCoordinateRegionMake(center.coordinate, span)
var regionQuery = geoFire.queryWithRegion(region)


class otherlocations: NSObject, MKAnnotation
{
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    
    init (title: String, locationName: String?, coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    //will show the name of the locations plotted
    var subtitle: String? {
        return locationName
    }
    
    
    
//    class func from (json:JSON) -> otherlocations?
//    {
//        var title: String
//        if let unwrappedTitle = json["email"].string {
//            title = unwrappedTitle
//        } else {
//            title = ""
//        }
//
//        let locationName = json["User"]["email"].string
//        let lat = json["User"]["lat"].doubleValue
//        let long = json["User"]["long"].doubleValue
//        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//
//        return otherlocations(title: title, locationName: locationName, coordinate: coordinate)
//    }
    
    func mapItem() -> MKMapItem
    {
        let addressDictionary = [String(kABPersonAddressStreetKey) : subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "\(title) \(subtitle)"
        
        return mapItem
    }
    }

