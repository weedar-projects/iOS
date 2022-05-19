//
//  GooglePlaceRepository.swift
//
//  Created by Vitaliy Tsyomenko 20.08.2021.
//

import Foundation

final class GooglePlaceRepository {
    
    static let shared = GooglePlaceRepository()
    
    private let baseUrl = "https://maps.googleapis.com/maps/api/place"
    private let googleApiKey = "AIzaSyD6pOe4aSRpTnR73QKYwmquQMjiK0lQXkI"
    private var searchDetails = false
    
    func searchLocation(_ searchLocation: String, finished: @escaping (Places)->())
    {
        guard searchLocation.count > 2 && !searchDetails else { return }
        guard let url = URL(string: "\(baseUrl)/autocomplete/json?input=\(searchLocation.replacingOccurrences(of: " ", with: "+"))+USA&key=\(googleApiKey)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                return
            }
            
            guard let places = try? JSONDecoder().decode(Places.self, from: data!) else {
                return
            }
            DispatchQueue.main.async {
                finished(places)
            }
        }.resume()
    }

    func detailsLocation(_ placeID: String, finished: @escaping (DeliveryPlace)->()) {
        searchDetails = true
        guard let url = URL(string: "\(baseUrl)/details/json?place_id=\(placeID)&fields=formatted_address,geometry,address_components&key=\(googleApiKey)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                return
            }
            
            guard let palaceDetails = try? JSONDecoder().decode(Places.GooglePlaceDetails.self, from: data!) else {
                return
            }
            
            let location = palaceDetails.result.geometry.location
            var deliveryPlace = DeliveryPlace(location: location)
            var route = ""
            var streetNumber = ""
            for item in palaceDetails.result.addressComponents.enumerated() {
                item.element.types.first { type in
                    switch type {
//                    case "administrative_area_level_1": //address
//                        deliveryPlace.addressLine1 = item.element.longName
//                        return true
                    case "locality": //city
                        deliveryPlace.city = item.element.longName
                        return true
                    case "postal_code": //zipCode
                        deliveryPlace.zipCode = item.element.longName
                        return true
                    case "route": //street
                        route = item.element.longName
                        return true
                    case "street_number":
                        streetNumber = item.element.longName
                        return true
                    default:
                        return false
                    }
                }
            }
            
            deliveryPlace.addressLine1 = "\(streetNumber) \(route)"
            DispatchQueue.main.async {
                deliveryPlace.formattedAddress = palaceDetails.result.formattedAddress
                finished(deliveryPlace)
                self.searchDetails = false
            }
        }.resume()
    }
}
