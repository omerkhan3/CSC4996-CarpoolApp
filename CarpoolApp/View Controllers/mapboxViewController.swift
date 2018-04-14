//
//  mapboxViewController.swift
//  CarpoolApp
//
//  Created by Matt on 4/14/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections


class mapboxViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {

    var mapView: NavigationMapView!
    var directionsRoute: Route?
    // #-end-code-snippet: navigation vc-variables-swift
    
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
    let locationManager = CLLocationManager()
    var currentPlacemark:CLPlacemark?
    
    
    
    
    // #-code-snippet: navigation view-did-load-swift
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
            riderDestinationLong = scheduledRideDetail?.riderEndPointLong
            riderStartCoord = CLLocationCoordinate2D(latitude: riderStartLat!, longitude: riderStartLong!)
            riderEndCoord = CLLocationCoordinate2D(latitude: riderDestinationLat!, longitude: riderDestinationLong!)
        }
        
        if (isMatchDetail == true) {
            if (mapMatchDetail?.Status == "Awaiting rider request.") {
                let start = otherlocations(title: "Start", locationName: "Start", coordinate: riderStartCoord!)
                let end = otherlocations(title: "End", locationName: "End", coordinate: riderEndCoord!)
                self.mapView.addAnnotation(start as! MGLAnnotation)
                self.mapView.addAnnotation(end as! MGLAnnotation)
                showRiderRouteOnMap(start: riderStartCoord!, destination: riderEndCoord!)
            } else {
                showDriverRouteOnMap(start: driverStartCoord!, riderPickup: riderStartCoord!, riderDropoff: riderEndCoord!, destination: driverEndCoord!)
            }
        }
        else if (isScheduledRide == true) {
            let start = otherlocations(title: "Start", locationName: "Start", coordinate: riderStartCoord!)
            let end = otherlocations(title: "End", locationName: "End", coordinate: riderEndCoord!)
            self.mapView.addAnnotation(start as! MGLAnnotation)
            self.mapView.addAnnotation(end as! MGLAnnotation)
            showDriverRouteOnMap(start: driverStartCoord!, riderPickup: riderStartCoord!, riderDropoff: riderEndCoord!, destination: driverEndCoord!)
        }
        
        mapView = NavigationMapView(frame: view.bounds)
        
        view.addSubview(mapView)
        
        // Set the map view's delegate
        mapView.delegate = self
        
        // Allow the map to display the user's location
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        // Add a gesture recognizer to the map view
        let setDestination = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        mapView.addGestureRecognizer(setDestination)
    }
    // #-end-code-snippet: navigation view-did-load-swift
    
    // #-code-snippet: navigation long-press-swift
   
    func showRiderRouteOnMap(start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        let startPlacemark = MGLAnnotation(coordinates: start, count: nil)
        let destinationPlacemark = MGLAnnotation(coordinate: destination, addressDictionary: nil)
        
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MGLPointAnnotation()
        
        if let location = startPlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MGLPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        self.mapView.showAnnotations(self.mapView.annotations!, animated: true)
        
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
        let startPlacemark = MGLPlacemark(coordinate: start, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: riderPickup, addressDictionary: nil)
        
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MGLPointAnnotation()
        
        if let location = startPlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MGLPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType = .automobile
        
        // Get directions
        let directions = Directions.calculate(self.directionsRoute)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
       
        }
    
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
    
    //self.mapView.showAnnotations([sourceAnnotation1, destinationAnnotation1], animated: true)
    //self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    
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
    //let rect1 = route1.polyline.boundingMapRect
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
    }
    
    self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation, sourceAnnotation2, destinationAnnotation2], animated: true)
}
    
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        // Create a basic point annotation and add it to the map
        let annotation = MGLPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Start navigation"
        mapView.addAnnotation(annotation)
        
        // Calculate the route from the user's location to the set destination
        calculateRoute(from: (mapView.userLocation!.coordinate), to: annotation.coordinate) { (route, error) in
            if error != nil {
                print("Error calculating route")
            }
        }
    }
    // #-end-code-snippet: navigation long-press-swift
    
    // #-code-snippet: navigation calculate-route-swift
    // Calculate route to be used for navigation
    func calculateRoute(from origin: CLLocationCoordinate2D,
                        to destination: CLLocationCoordinate2D,
                        completion: @escaping (Route?, Error?) -> ()) {
        
        // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        
        // Specify that the route is intended for automobiles avoiding traffic
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        
        // Generate the route object and draw it on the map
        _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
            self.directionsRoute = routes?.first
            // Draw the route on the map after creating it
            self.drawRoute(route: self.directionsRoute!)
        }
    }
    // #-end-code-snippet: navigation calculate-route-swift
    
    // #-code-snippet: navigation draw-route-swift
    func drawRoute(route: Route) {
        guard route.coordinateCount > 0 else { return }
        // Convert the route’s coordinates into a polyline
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        // If there's already a route line on the map, reset its shape to the new route
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = MGLStyleValue(rawValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = MGLStyleValue(rawValue: 3)
            
            // Add the source and style layer of the route line to the map
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
    }
  
    
    // #-code-snippet: navigation callout-functions-swift
    // Implement the delegate method that allows annotations to show callouts when tapped
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    // Present the navigation view controller when the callout is selected
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        let navigationViewController = NavigationViewController(for: directionsRoute!)
        self.present(navigationViewController, animated: true, completion: nil)
    }
 
    
    
}


