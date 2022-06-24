//
//  LocationManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 21.06.2022.
//

import Foundation
import CoreLocation
import MapKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined
    
    @Published var userLocation: CLLocation?
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.0422448, longitude: -102.0079053),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )

    @Published var currentAddressName: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation(currentAddress: @escaping (String,String) -> Void) {
        locationManager.requestLocation()
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            guard let userLocation = self.userLocation else {return}
            self.getAdressName(coords: userLocation){address, zipcode in
                currentAddress(address,zipcode)
            }
        }
    }
    
    func getAdressName(coords: CLLocation, currentAddress: @escaping (String,String) -> Void) {
        CLGeocoder().reverseGeocodeLocation(coords) { (placemark, error) in
                if error != nil {
                    print("Hay un error")
                } else {

                    let place = placemark! as [CLPlacemark]
                    if place.count > 0 {
                        let place = placemark![0]
                        var addressString : String = ""
                        if place.thoroughfare != nil {
                            addressString = addressString + place.thoroughfare! + ", "
                        }
                        if place.subThoroughfare != nil {
                            addressString = addressString + place.subThoroughfare! + ", "
                        }
                        if place.locality != nil {
                            addressString = addressString + place.locality! + ", "
                        }
                        if place.postalCode != nil {
                            addressString = addressString + place.postalCode! + ", "
                        }
                        if place.subAdministrativeArea != nil {
                            addressString = addressString + place.subAdministrativeArea! + ", "
                        }
                        if place.country != nil {
                            addressString = addressString + place.country!
                        }
                        currentAddress(addressString, place.postalCode ?? "")
                        self.currentAddressName = addressString
                    }
                }
            }
      }
    
    func checkDistance(coord1: CLLocation, coord2: CLLocation) -> Double{
        let distanceInMiles = coord1.distance(from: coord2) / 1609
        print("DISTANCE: \(distanceInMiles)")
        return distanceInMiles
    }
    
    public func requestAuthorisation(always: Bool = false) {
        if always {
            self.locationManager.requestAlwaysAuthorization()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorisationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.userLocation = location
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //Handle any errors here...
        print (error)
    }
}
