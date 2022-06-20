//
//  GoogleMapsViewController.swift
//  TestLocationApp
//
//  Created by Apple on 18/06/2022.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON
import SCLAlertView

class GoogleMapsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var map: GMSMapView!
    
    //MARK: - Properties
    var locationManager: CLLocationManager!
    
    var timer = Timer()
    
    var sourceLocation = CLLocationCoordinate2D(latitude: 33.99983999474079, longitude: 72.9388732840795)
//    let destinationLocation = CLLocationCoordinate2D(latitude: 37.564061915632664, longitude: -122.3374326826298)
    let destinationLocation = CLLocationCoordinate2D(latitude: 37.43004758130163, longitude: -122.2488554113968)

    var oldPolyLines = [GMSPolyline]()
    
    let APIKEY = "AIzaSyBZb0XTP9n9WFVvdOrVbpn_uSw3eCPQLGo"
    
    //MARK: - Built-In functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Google Maps"
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        scheduledTimerWithTimeInterval()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //adding location markers
        addMakers()
        
        //loading maps with polyline and current location
        loadAllMapsStuff(currentLocation: sourceLocation, destinationLocation: destinationLocation)
    }
    
    //MARK: - Imp Functions
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
        print("Time Interval: \(timer.timeInterval)")
    }
    
    @objc func updateCounting(){
        NSLog("counting..")
        loadAllMapsStuff(currentLocation: sourceLocation, destinationLocation: destinationLocation)
    }
    
    func loadAllMapsStuff(currentLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocation.latitude),\(currentLocation.longitude)&destination=\(destinationLocation.latitude),\(destinationLocation.longitude)&mode=driving&key=\(APIKEY)"
        
        print(url)
        
        AF.request(url).response { (response) in
            
            guard let data = response.data else {return}
            
            do {
                let json = try JSON(data: data)
                let routes = json["routes"].arrayValue
                
                for route in routes {
                    
                    let overViewPolyline = route["overview_polyline"].dictionary
                    let points = overViewPolyline?["points"]?.string
                    let path = GMSPath.init(fromEncodedPath: points ?? "")
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeColor = .systemBlue
                    polyline.strokeWidth = 5
                    
                    if self.oldPolyLines.count > 0 {
                        for polyline in self.oldPolyLines {
                            polyline.map = nil
                        }
                    }
                    self.oldPolyLines.append(polyline)
                    polyline.map = self.map
                    
                    DispatchQueue.main.async {
                        
                        if self.map != nil && path != nil {
                            
                            let bounds = GMSCoordinateBounds(path: path!)
                            self.map!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
                        }
                    }
                }
            }catch{
                
                SCLAlertView().showError("Error", subTitle: "\(error.localizedDescription)")
                print(error.localizedDescription)
            }
        }
    }
    
    func addMakers() {
        
        /// Marker - Google Place marker
        let marker: GMSMarker = GMSMarker()
        let destinationMarker = GMSMarker()
        
        marker.title = "Resturent"
        marker.snippet = "Parcel Pick up Location"
        marker.icon = UIImage(named: "")
        marker.appearAnimation = .pop
        marker.position = sourceLocation
        
        DispatchQueue.main.async {
            marker.map = self.map
        }
        
        destinationMarker.title = "Destination"
        destinationMarker.snippet = "Parcel drop off location."
        destinationMarker.icon = UIImage(named: "")
        destinationMarker.appearAnimation = .pop
        destinationMarker.position = destinationLocation
        
        DispatchQueue.main.async {
            destinationMarker.map = self.map
        }
    }
}

//MARK: - Class extensions
extension GoogleMapsViewController: CLLocationManagerDelegate {
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {return}
        
        sourceLocation = location.coordinate
        
//        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17.0)
//        self.map?.animate(to: camera)
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.requestLocation()
            map.isMyLocationEnabled = true
            map.settings.myLocationButton = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        //self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
//        SCLAlertView().showError("Error", subTitle: "\(error.localizedDescription)")
        print("Location Not Found.")
    }
}
