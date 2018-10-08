//
//  gpsViewController.swift
//  GPStwo
//
//  Created by discusit on 08/10/18.
//  Copyright © 2018 dbs. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
//AIzaSyA7hwq_2F3Q40MZkuGnc5_do_WXh2oETVY
class gpsViewController: UIViewController ,CLLocationManagerDelegate,GMSMapViewDelegate{
      @IBOutlet weak var googleMaps: GMSMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.activityType = .other
        locationManager.showsBackgroundLocationIndicator.toggle()
        placesClient = GMSPlacesClient.shared()
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            locationManager.startUpdatingLocation()
            
           // mapView.settings.myLocationButton = true
            currentLocation = locationManager.location
            
        }
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        //Your map initiation code
        //        let camera = GMSCameraPosition.camera(withLatitude:(locationManager.location?.coordinate.latitude)!, longitude:(locationManager.location?.coordinate.longitude)!, zoom: 15.0)
        //
        //        self.googleMaps.camera = camera
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        self.googleMaps.settings.allowScrollGesturesDuringRotateOrZoom = true
        self.googleMaps.settings.setAllGesturesEnabled(true)
        self.googleMaps.settings.indoorPicker = true
        
        
       
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation?.coordinate.latitude ?? 00.000000,
                                              longitude: currentLocation?.coordinate.longitude ?? 00.000000,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //mapView.isMyLocationEnabled = true
       
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
     

    }
}
extension gpsViewController {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location LAT: \(location.coordinate.latitude) LONG: \(location.coordinate.longitude)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        listLikelyPlaces()
    }
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
        })
    }
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
extension gpsViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // Change map location
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0
        )
        // set coordinate to text
//        if locationSelected == .startLocation {
//            startLocation.text = place.formattedAddress
//            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//            createMarker(titleMarker: place.formattedAddress!, iconMarker: #imageLiteral(resourceName: "Location_icon"), latitude: place.coordinate.latitude,longitude: place.coordinate.longitude)
//        }
//            
//        else
//        {
//            destinationLocation.text = place.formattedAddress
//            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//            wayPoint = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//            
//            createMarker(titleMarker: place.formattedAddress!, iconMarker: #imageLiteral(resourceName: "Location_icon"), latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//        }
        self.googleMaps.camera = camera
        self.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}
