//
//  PickUpRootVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.06.2022.
//

import SwiftUI
import MapKit
import SwiftyJSON
import Alamofire

class PickUpRootVM: ObservableObject{
    
    @Published var selectedTab: PickUpShopListState = .list
    @Published var selectedStore: StoreModel?
    @Published var selectedRadius: Double = 20{
        didSet{
            self.getStores(radius: selectedRadius)
        }
    }
    @Published var showStoreInfo = false
    
    @Published var availableStores: [StoreModel] = []
    
    @Published var availableStoresList: [StoreModel] = []
    
    @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    @Published var error = ""
    
    @Published var showRaduisPicker = false
    
    @Published var emptyStores = false
    
    @Published var createdOrder: OrderResponseModel?
    
    @Published var userData: UserModel?{
        didSet{
            guard let address = userData?.addresses.first else { return }
            self.address = address.addressLine1
            self.latitudeCoordinate = address.latitudeCoordinate
            self.longitudeCoordinate = address.longitudeCoordinate
            self.zipCode = zipCode
        }
    }
    
    @Published var address = ""
    @Published var latitudeCoordinate: Double = 0
    @Published var longitudeCoordinate: Double = 0
    @Published var zipCode = ""
    
    @Published var showDirectionsView = false
    
    @Published var alertMessage = ""
    @Published var showerrorAlert = false
    
    func getStores(radius: Double){
        API.shared.request(rout: .getAllStores, method: .get) { result in
            switch result{
            case let .success(json):
                self.availableStores.removeAll()
                self.availableStoresList.removeAll()
                let stores = json.arrayValue.map({StoreModel(json: $0)})
                for store in stores{
                    if LocationManager().checkDistance(coord1: CLLocation(latitude: store.latitudeCoordinate,
                                                                          longitude: store.longitudeCoordinate),
                                                       coord2: CLLocation(latitude: self.latitudeCoordinate,
                                                                          longitude: self.longitudeCoordinate)) <= radius{
                        
                        let distance = LocationManager().checkDistance(coord1: CLLocation(latitude: store.latitudeCoordinate,
                                                                                          longitude: store.longitudeCoordinate),
                                                                       coord2: CLLocation(latitude: self.latitudeCoordinate,
                                                                                          longitude: self.longitudeCoordinate))
                        let storeWithDistance = StoreModel(id: store.id, address: store.address, phone: store.phone, latitudeCoordinate: store.latitudeCoordinate, longitudeCoordinate: store.longitudeCoordinate, timeWork: store.timeWork, daysWork: store.daysWork, close: store.close, distance: distance)
                        self.availableStores.append(storeWithDistance)
                        self.availableStoresList.append(storeWithDistance)
                    }
                }
                self.availableStores.append(StoreModel(id: Int.random(in: 0...9999), address: self.address, phone: "", latitudeCoordinate: self.latitudeCoordinate, longitudeCoordinate: self.longitudeCoordinate, timeWork: "", daysWork: "", close: true, isMyLocation: true, radius: radius))
                self.mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.latitudeCoordinate, longitude: self.longitudeCoordinate), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            case let .failure(error):
                self.error = error.message
            }
        }
    }
    
    func makeOrder(success: @escaping (OrderResponseModel)->Void) {
        //{ delivery = 0, pickUp = 1 }
        guard let user = userData, let storeId = selectedStore?.id else { return  }
        
        let params: Parameters = [
            "name": user.name,
            "type": 1,
            "pickUpPartnerId": storeId
        ]
        
        API.shared.request(rout: .getOrderById, method: .post, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case let .success(json):
                let order = OrderResponseModel(json: json)
                success(order)
            case let .failure(error):
                self.alertMessage = error.message
                self.showerrorAlert = true
            }
        }
    }
    
    func getCreatedOrder(order: OrderResponseModel?) -> OrderDetailsReview {
        guard let createdOrder = order else {
            return OrderDetailsReview(orderId: 0,
                                      totalSum: 0,
                                      exciseTaxSum: 0,
                                      salesTaxSum: 0,
                                      localTaxSum: 0,
                                      taxSum: 0,
                                      sum: 0,
                                      state: 0,
                                      fullAdress: "",
                                      username: "",
                                      phone: "",
                                      partnerPhone: "",
                                      partnerName: "",
                                      partnerAdress: "",
                                      orderNumber: ""
            )
        }
        
        
        return OrderDetailsReview(orderId: createdOrder.id, totalSum: createdOrder.totalSum, exciseTaxSum: createdOrder.exciseTaxSum,totalWeight: createdOrder.gramWeight.formattedString(format: .gramm), salesTaxSum: createdOrder.salesTaxSum, localTaxSum: createdOrder.taxSum,discount: createdOrder.discount , taxSum: createdOrder.taxSum, sum: createdOrder.sum, state: createdOrder.state, fullAdress: createdOrder.partner.address, username: createdOrder.name, phone: createdOrder.phone,partnerPhone: createdOrder.partner.phone, partnerName: createdOrder.partner.name, partnerAdress: createdOrder.partner.address, orderNumber: createdOrder.number)
    }
}
