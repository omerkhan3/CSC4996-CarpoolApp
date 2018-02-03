//
//  otherlocations.swift
//  CarpoolApp
//
//  Created by Matt on 2/3/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import Foundation
import MapKit
import AddressBook


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
}
