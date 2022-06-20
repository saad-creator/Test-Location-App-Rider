//
//  RedrawPolylineViewController.swift
//  TestLocationApp
//
//  Created by Apple on 16/06/2022.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

class RedrawPolylineViewController: UIViewController {
    
    var demoPolyline = GMSPolyline()
    var demoPolylineOLD = GMSPolyline()
    
    // Set Destination Location Cordinates
    var destinationLocation = CLLocation(latitude: 23.072837, longitude: 72.516455)
    
    //MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    
    let sourceLocation = CLLocationCoordinate2D(latitude: 28.704060, longitude: 77.102493)
//    let destinationLocation = CLLocationCoordinate2D(latitude: 33.62502131416934, longitude: 73.06329989154959)
    
    //MARK: - Properties
    var locationManager: CLLocationManager!
    var allLocations: [CLLocation] = []
    
    //MARK: - Built-In Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        // user activated automatic authorization info mode
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        //mapview setup to show user location
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
    }
    
    func createPath(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D) {
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        let sourceAnotation = MKPointAnnotation()
        sourceAnotation.title = "Starting Point"
        sourceAnotation.subtitle = "To be picked up form here"
        if let location = sourcePlaceMark.location {
            sourceAnotation.coordinate = location.coordinate
        }
        
        let destinationAnotation = MKPointAnnotation()
        destinationAnotation.title = "Destination"
        destinationAnotation.subtitle = "To be delivered Here"
        if let location = destinationPlaceMark.location {
            destinationAnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnotation, destinationAnotation], animated: true)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .automobile
        
        let direction = MKDirections(request: directionRequest)
        
        
        direction.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("ERROR FOUND : \(error.localizedDescription)")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
}

extension RedrawPolylineViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendere = MKPolylineRenderer(overlay: overlay)
        rendere.lineWidth = 5
        rendere.strokeColor = .black
        rendere.fillColor = .black
        return rendere
    }
}

//MARK: - Controller Extensions
extension RedrawPolylineViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocation = locations.last!
        
        guard let currentLocation = locations.first(where: { $0.horizontalAccuracy >= 0 }) else {
            return
        }

        
             let originalLoc: String = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
             let destiantionLoc: String = "\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)"

             let latitudeDiff: Double = Double(location.coordinate.latitude) - Double(destinationLocation.coordinate.latitude)
             let longitudeDiff: Double = Double(location.coordinate.longitude) - Double(destinationLocation.coordinate.longitude)

             let waypointLatitude = location.coordinate.latitude - latitudeDiff
             let waypointLongitude = location.coordinate.longitude - longitudeDiff
        createPath(sourceLocation: currentLocation.coordinate, destinationLocation: destinationLocation.coordinate)
    }
}

