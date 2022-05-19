//
//  GooglePlace.swift
//  CannabisShop
//
//  Created by Vitaliy Tsyomenko on 19.08.2021.
//

import Foundation

struct Places: Codable {
    var predictions: [Prediction]
    let status: String
    
    struct Prediction: Codable, Hashable {
        static func == (lhs: Prediction, rhs: Prediction) -> Bool {
            return lhs.placeID == rhs.placeID
        }
        
        let predictionDescription: String
        let placeID, reference: String
        let structuredFormatting: StructuredFormatting
        let terms: [Term]
        let types: [String]

        enum CodingKeys: String, CodingKey {
            case predictionDescription = "description"
            case placeID = "place_id"
            case reference
            case structuredFormatting = "structured_formatting"
            case terms, types
        }
    }

    struct StructuredFormatting: Codable, Hashable {
        let mainText: String
        let secondaryText: String

        enum CodingKeys: String, CodingKey {
            case mainText = "main_text"
            case secondaryText = "secondary_text"
        }
    }

    struct Term: Codable, Hashable {
        let offset: Int
        let value: String
    }

    struct GooglePlaceDetails: Codable {
        let result: Result
        let status: String

        enum CodingKeys: String, CodingKey {
            case result, status
        }
    }

    struct Result: Codable {
        let addressComponents: [AddressComponent]
        let formattedAddress: String
        let geometry: Geometry

        enum CodingKeys: String, CodingKey {
            case addressComponents = "address_components"
            case formattedAddress = "formatted_address"
            case geometry
        }
    }

    struct Geometry: Codable {
        let location: Locations
    }

    

    struct AddressComponent: Codable {
        let longName, shortName: String
        let types: [String]

        enum CodingKeys: String, CodingKey {
            case longName = "long_name"
            case shortName = "short_name"
            case types
        }
    }
}

struct DeliveryPlace {
    var location: Locations
    var city: String?
    var addressLine1: String?
    var zipCode: String?
    var formattedAddress: String?
}

struct Locations: Codable {
    let lat, lng: Double
}
