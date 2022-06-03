//
//  OrderTrackerManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.04.2022.
//

import SwiftUI
import Starscream
import SwiftyJSON


class OrderTrackerManager: ObservableObject, WebSocketDelegate{
    
    let allState: [OrderTrackerStateModel] = [
        OrderTrackerStateModel(id: 0, state: .submited,
                               colors: [Color.col_gradient_orange_first, Color.col_gradient_orange_second],
                               deliveryText: "Delivery partner is reviewing your order."),
        OrderTrackerStateModel(id: 1, state: .packing,
                               colors: [Color.col_violet_status_bg, Color.col_white],
                               deliveryText: "Delivery partner is preparing your order."),
        OrderTrackerStateModel(id: 2,
                               state: .inDelivery,
                               colors: [Color.col_gradient_blue_first, Color.col_gradient_blue_second],
                               deliveryText: "The driver is on the way."),
        OrderTrackerStateModel(id: 3,
                               state: .delivered,
                               colors: [Color.col_gradient_green_first, Color.col_gradient_green_second],
                               deliveryText: "The order is delivered.Thank you for choosing WEEDAR.")
    ]
    
    @Published var isConnected = false
    
    @Published var showPosition: OrderTrackerPosition = .notUse
    
    @Published var avaibleCount = 0
    
    @Published var currentState: OrderTrackerStateModel?{
        didSet {
            if currentState?.id == 3{
                withAnimation{
                    hideProgressPoints = true
                }
            }else{
                withAnimation{
                    hideProgressPoints = false
                }
            }
        }
    }
    
    @Published var needToShow = true
    
    @Published var aviableOrders: [OrderTrackerModel] = []{
        didSet{
            print("aviable orders updated")
            currentOrder = currentOrder != nil ? aviableOrders.first(where: {$0.id == currentOrder?.id}) ?? aviableOrders.first : aviableOrders.first
            
            avaibleCount = aviableOrders.count
            
            if aviableOrders.isEmpty{
                NotificationCenter.default.post(name: .hideOrderTracker, object: nil)
                showPosition = .hide
            }else if !needToShow{
                NotificationCenter.default.post(name: .hideOrderTracker, object: nil)
                showPosition = .hide
            }else{
                NotificationCenter.default.post(name: .showOrderTracker, object: nil)
            }
            
        }
    }
    
    @Published var hideProgressPoints = false
    
    @Published var currentOrder: OrderTrackerModel?{
        didSet{
            switch currentOrder?.state{
            case 1:
                currentState = allState[0]
            case 5:
                currentState = allState[1]
            case 6:
                currentState = allState[2]
            case 7:
                currentState = allState[3]
            default:
                currentState = allState[0]
            }
        }
    }
    
    private var token : String?  { return KeychainService.loadPassword(serviceKey: .accessToken) }
    
    private var socket: WebSocket?
    
    func connect() {
        if !isConnected{
            guard let token = self.token else { return }
            var request = URLRequest(url: URL(string: PKSettingsBundleHelper.shared.currentEnvironment.baseUrl.appending("/websocket"))!)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            socket = WebSocket(request: request)
            socket?.delegate = self
            socket?.connect()
            isConnected = true
            update()
            print("HEADER: \(request.headers)")
            print("socket connect")
        }
    }
    
    
    func disconnect() {
        if isConnected{
            socket?.disconnect(closeCode: CloseCode.normal.rawValue)
            print("socket disconnect")
            isConnected = false
        }
    }
    
    func update() {
        socket?.write(ping: "ping".data(using: .utf8)!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            if self.isConnected{
                self.update()
                print("ping")
            }
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            DispatchQueue.main.async {
                let dataJson = JSON(parseJSON: string)
                let aviableOrders = dataJson["data"].arrayValue.map({OrderTrackerModel(json: $0)})
                self.aviableOrders = aviableOrders
                print("Current Orders Tracker: \(dataJson)")
            }
        case .binary(let data):
            print("Received data: \(data)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
    


}

struct OrderTrackerModel: Identifiable{
    var id: Int
    var number: String
    var name: String
    var phone: String
    var city: String
    var addressLine1: String
    var addressLine2: String?
    var zipCode: String
    var sum: Double
    var deliverySum: Int
    var totalSum: Double
    var exciseTaxSum: Double
    var salesTaxSum: Double
    var cityTaxSum: Double
    var taxSum: Double
    var profitSum: Double
    var createdAt: String
    var state: Int
    var comment: String?
    var updatedAt: String
    var discount: DiscountModel?
    var latitudeCoordinate: Double
    var longitudeCoordinate: Double
    var userId: Int?
    var detailCount: Int?
    var orderDetails: [OrderDetailsModel]
    
    init(json: JSON) {
        
        self.id = json["id"].intValue
        self.number = json["number"].stringValue
        self.name = json["name"].stringValue
        self.phone = json["phone"].stringValue
        self.city = json["city"].stringValue
        self.addressLine1 = json["addressLine1"].stringValue
        self.addressLine2 = json["addressLine2"].stringValue
        self.zipCode = json["zipCode"].stringValue
        self.sum = json["sum"].doubleValue
        self.deliverySum = json["deliverySum"].intValue
        self.totalSum = json["totalSum"].doubleValue
        self.exciseTaxSum = json["exciseTaxSum"].doubleValue
        self.salesTaxSum = json["salesTaxSum"].doubleValue
        self.cityTaxSum = json["cityTaxSum"].doubleValue
        self.taxSum = json["taxSum"].doubleValue
        self.profitSum = json["profitSum"].doubleValue
        self.createdAt = json["createdAt"].stringValue
        self.state = json["state"].intValue
        self.comment = json["comment"].string
        self.updatedAt = json["updatedAt"].stringValue
        self.latitudeCoordinate = json["latitudeCoordinate"].doubleValue
        self.longitudeCoordinate = json["longitudeCoordinate"].doubleValue
        self.userId = json["userId"].intValue
        self.detailCount = json["detailCount"].intValue
        self.discount = DiscountModel(json: json["discount"])
        self.orderDetails = json["orderDetails"].arrayValue.map({ OrderDetailsModel(json: $0)})
    }
    

}

struct OrderDetailsModel: Identifiable{
    var id: Int
    var quantity: Int
    var createdAt: String
    var productId: Int
    var orderId: Int
    var product: ProductModel
    
    init(json: JSON){
        self.id = json["id"].intValue
        self.quantity = json["quantity"].intValue
        self.createdAt = json["createdAt"].stringValue
        self.productId = json["productId"].intValue
        self.orderId = json["orderId"].intValue
        self.product = ProductModel(json: json["product"])
    }
}

