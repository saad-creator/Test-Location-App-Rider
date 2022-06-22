//
//  ViewController.swift
//  TestLocationApp
//
//  Created by Apple on 15/06/2022.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

//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

class ViewController: UIViewController {
    
    var demoPolyline = GMSPolyline()
    var demoPolylineOLD = GMSPolyline()

    //MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
        
    //MARK: - Properties
    var locationManager: CLLocationManager!
    var allLocations: [CLLocation] = []
    
    // Set Destination Location Cordinates
    let sourceLocation = CLLocationCoordinate2D(latitude: 33.641646911422306, longitude: 73.06248365860773)
    var destinationLocation = CLLocationCoordinate2D(latitude: 33.62492466400066, longitude: 73.0625694892976)
    
    //MARK: - Built-In Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Apple Maps"
        
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
        
        let startLocation = CLLocation(latitude: 33.62492466400066, longitude: 73.0625694892976)
        let endLocation = CLLocation(latitude: 33.641646911422306, longitude: 73.06248365860773)
        
        createPath(sourceLocation: startLocation.coordinate, destinationLocation: endLocation.coordinate)
    }
    
    func createPath(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D) {
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        let sourceAnotation = MKPointAnnotation()
        sourceAnotation.title = "Starting Point"
        sourceAnotation.subtitle = "Parcel to be picked up from here"
        if let location = sourcePlaceMark.location {
            sourceAnotation.coordinate = location.coordinate
        }
        
        let destinationAnotation = MKPointAnnotation()
        destinationAnotation.title = "Destination"
        destinationAnotation.subtitle = "Parcel to be delivered Here"
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
    
    //MARK: - IBActions
    
    @IBAction func goToGoogleMapsTapped(_ sender: UIButton) {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "GoogleMapsViewController") as? GoogleMapsViewController {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ViewController : MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let rendere = MKPolylineRenderer(overlay: overlay)
        rendere.lineWidth = 5
        rendere.strokeColor = .black
        rendere.fillColor = .black
        return rendere
    }
}

//MARK: - Controller Extensions
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        guard let currentLocation = locations.first(where: { $0.horizontalAccuracy >= 0 }) else {
            return
        }
        
        createPath(sourceLocation: currentLocation.coordinate, destinationLocation: destinationLocation)
        
        let previousCoordinate = allLocations.last?.coordinate
        allLocations.append(currentLocation)
        
        if previousCoordinate == nil { return }
    }
}
