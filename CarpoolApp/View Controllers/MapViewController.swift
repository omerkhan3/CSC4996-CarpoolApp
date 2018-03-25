//
//  MapViewController.swift
//  CarpoolApp
//
//  Created by Matt on 2/1/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth

//MOE
protocol MapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // Class variables

    var mapMatchDetail: Match?
    var scheduledRideDetail: ScheduledRide?
    var isMatchDetail = false
    var isScheduledRide = false
    
    var driverStartLat: Double?
    var driverStartLong: Double?
    var driverDestinationName: Double?
    var driverDestinationLat: Double?
    var driverDestinationLong: Double?
    var driverStartCoord: CLLocationCoordinate2D?
    var driverEndCoord: CLLocationCoordinate2D?
    var riderStartLat: Double?
    var riderStartLong: Double?
    var riderDestinationLat: Double?
    var riderDestinationLong: Double?
    var riderStartCoord: CLLocationCoordinate2D?
    var riderEndCoord: CLLocationCoordinate2D?
    
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var currentPlacemark:CLPlacemark?
    

    

    //linking mapview to this class
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Driver points (Match)
        if (isMatchDetail == true){
            driverStartLat = mapMatchDetail?.driverStartPointLat
            driverStartLong = mapMatchDetail?.driverStartPointLong
            //let driverDestinationName = mapMatchDetail?.driverRouteName
            driverDestinationLat = mapMatchDetail?.driverEndPointLat
            driverDestinationLong = mapMatchDetail?.driverEndPointLong
            driverStartCoord = CLLocationCoordinate2D(latitude: driverStartLat!, longitude: driverStartLong!)
            driverEndCoord = CLLocationCoordinate2D(latitude: driverDestinationLat!, longitude: driverDestinationLong!)
            
            // Rider points (Match)
            riderStartLat = mapMatchDetail?.riderStartPointLat
            riderStartLong = mapMatchDetail?.riderStartPointLong
            riderDestinationLat = mapMatchDetail?.riderEndPointLat
            riderDestinationLong = mapMatchDetail?.riderEndPointLong
            riderStartCoord = CLLocationCoordinate2D(latitude: riderStartLat!, longitude: riderStartLong!)
            riderEndCoord = CLLocationCoordinate2D(latitude: riderDestinationLat!, longitude: riderDestinationLong!)
        }
        
        // Driver Points (Scheduled Ride)
        if (isScheduledRide == true) {
            
            driverStartLat = scheduledRideDetail?.driverStartPointLat
            driverStartLong = scheduledRideDetail?.driverStartPointLong
            //let driverDestinationName = scheduledRideDetail?.driverRouteName
            driverDestinationLat = scheduledRideDetail?.driverEndPointLat
            driverDestinationLong = scheduledRideDetail?.driverEndPointLong
            driverStartCoord = CLLocationCoordinate2D(latitude: driverStartLat!, longitude: driverStartLong!)
            driverEndCoord = CLLocationCoordinate2D(latitude: driverDestinationLat!, longitude: driverDestinationLong!)
            
            // Rider points (Match)
            riderStartLat = scheduledRideDetail?.riderStartPointLat
            riderStartLong = scheduledRideDetail?.riderStartPointLong
            riderDestinationLat = scheduledRideDetail?.riderEndPointLat
            driverDestinationLong = scheduledRideDetail?.riderEndPointLong
            riderStartCoord = CLLocationCoordinate2D(latitude: riderStartLat!, longitude: riderStartLong!)
            riderEndCoord = CLLocationCoordinate2D(latitude: riderDestinationLat!, longitude: driverDestinationLong!)
        }
        
        // Set up Map
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        mapView.showsUserLocation = true
        
        if (isMatchDetail == true) {
            if (mapMatchDetail?.Status == "Awaiting rider request.") {
                let start = otherlocations(title: "Start", locationName: "Start", coordinate: riderStartCoord!)
                let end = otherlocations(title: "End", locationName: "End", coordinate: riderEndCoord!)
                self.mapView.addAnnotation(start)
                self.mapView.addAnnotation(end)
                showRiderRouteOnMap(start: riderStartCoord!, destination: riderEndCoord!)
            } else {
                showDriverRouteOnMap(start: driverStartCoord!, riderPickup: riderStartCoord!, riderDropoff: riderEndCoord!, destination: driverEndCoord!)
            }
        }
        else if (isScheduledRide == true) {
            let start = otherlocations(title: "Start", locationName: "Start", coordinate: riderStartCoord!)
            let end = otherlocations(title: "End", locationName: "End", coordinate: riderEndCoord!)
            self.mapView.addAnnotation(start)
            self.mapView.addAnnotation(end)
            showDriverRouteOnMap(start: driverStartCoord!, riderPickup: riderStartCoord!, riderDropoff: riderEndCoord!, destination: driverEndCoord!)
        }
    }

    //Brings up the user on the map after authorization
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func showRiderRouteOnMap(start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        let startPlacemark = MKPlacemark(coordinate: start, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = startPlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType = .automobile
        
        // Get directions
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            
        }
        
    }
    
    func showDriverRouteOnMap(start: CLLocationCoordinate2D, riderPickup: CLLocationCoordinate2D, riderDropoff: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        // Route from driver start to rider pickup
        let startPlacemark = MKPlacemark(coordinate: start, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: riderPickup, addressDictionary: nil)
        
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = startPlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType = .automobile
        
        // Get directions
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
            
        // Route from rider pickup to rider dropoff
            let startPlacemark1 = MKPlacemark(coordinate: riderPickup, addressDictionary: nil)
            let destinationPlacemark1 = MKPlacemark(coordinate: riderDropoff, addressDictionary: nil)
        
            let startMapItem1 = MKMapItem(placemark: startPlacemark1)
            let endMapItem1 = MKMapItem(placemark: destinationPlacemark1)
        
            let sourceAnnotation1 = MKPointAnnotation()
            
            if let location = startPlacemark1.location {
                sourceAnnotation1.coordinate = location.coordinate
            }
            
            let destinationAnnotation1 = MKPointAnnotation()
        
            if let location1 = destinationPlacemark.location {
                destinationAnnotation1.coordinate = location1.coordinate
            }
        
            self.mapView.showAnnotations([sourceAnnotation1, destinationAnnotation1], animated: true)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        
            let directionRequest1 = MKDirectionsRequest()
            directionRequest1.source = startMapItem1
            directionRequest1.destination = endMapItem1
            directionRequest1.transportType = .automobile
            
            // Get directions
            let directions1 = MKDirections(request: directionRequest1)
        
            directions1.calculate {
                (response, error) -> Void in
                
                guard let response = response else {
                    if let error = error {
                        print("error: \(error)")
                    }
                    return
                }
                
                let route1 = response.routes[0]
                
                self.mapView.add((route1.polyline), level: MKOverlayLevel.aboveRoads)
                let rect1 = route1.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegionForMapRect(rect1), animated: true)
            }
        
            // Route from rider dropoff to driver destination
                let startPlacemark2 = MKPlacemark(coordinate: riderDropoff, addressDictionary: nil)
                let destinationPlacemark2 = MKPlacemark(coordinate: destination, addressDictionary: nil)
                
                let startMapItem2 = MKMapItem(placemark: startPlacemark2)
                let endMapItem2 = MKMapItem(placemark: destinationPlacemark2)
                
                let sourceAnnotation2 = MKPointAnnotation()
                
                if let location2 = startPlacemark2.location {
                    sourceAnnotation2.coordinate = location2.coordinate
                }
                
                let destinationAnnotation2 = MKPointAnnotation()
                
                if let location2 = destinationPlacemark2.location {
                    destinationAnnotation2.coordinate = location2.coordinate
                }
                
                self.mapView.showAnnotations([sourceAnnotation2, destinationAnnotation2], animated: true)
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                
                let directionRequest2 = MKDirectionsRequest()
                directionRequest2.source = startMapItem2
                directionRequest2.destination = endMapItem2
                directionRequest2.transportType = .automobile
                
                // Get directions
                let directions2 = MKDirections(request: directionRequest2)
                
                directions2.calculate {
                    (response, error) -> Void in
                    
                    guard let response = response else {
                        if let error = error {
                            print("error: \(error)")
                        }
                        return
                    }
                    
                    let route2 = response.routes[0]
                    
                    self.mapView.add((route2.polyline), level: MKOverlayLevel.aboveRoads)
                    let rect2 = route2.polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegionForMapRect(rect2), animated: true)
                }
    }
    
    //selecting an annotation will call this method
    func mapView(_ mapView:MKMapView, didSelect view:MKAnnotationView)
    {
        //grab annotation from current location
        if let location = view.annotation as? otherlocations{
        self.currentPlacemark = MKPlacemark(coordinate: location.coordinate)
        }
    }
    //function that is called when polygon line is drawn, can set size and color
    func mapView(_ mapView:MKMapView, rendererFor overlay:MKOverlay) ->MKOverlayRenderer
    {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.green
        renderer.lineWidth = 3.5
        
        return renderer
    }
}

////Uses the protocol we created mapsearch, clears map of any other annotations on it, and mkpointannotation has the coordinate, subtitle(city, state), and title of the place(ex. H&M)
//extension MapViewController: MapSearch {
//    func dropPinZoomIn(placemark:MKPlacemark) {
//        selectedPin = placemark
//        // clear existing pins
//        mapView.removeAnnotations(mapView.annotations)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = placemark.coordinate
//        annotation.title = placemark.name
//        if let city = placemark.locality,
//            let state = placemark.administrativeArea {
//            annotation.subtitle = "(city) (state)"
//        }
//        //Add the annotation stated above(city, state)
//        mapView.addAnnotation(annotation)
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        //Will zoom in the map to the coordinate of the place chosen
//        let region = MKCoordinateRegionMake(placemark.coordinate, span)
//        mapView.setRegion(region, animated: true)
//    }
//}

