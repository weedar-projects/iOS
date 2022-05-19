//
//  NetworkConnection.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.05.2022.
//

import SwiftUI
import Foundation
import Network

class NetworkConnection: ObservableObject {
    let monitor = NWPathMonitor()
    
    let queue = DispatchQueue(label: "NetworkManager")
    
    @Published var isConnected = true{
        didSet{
            print("Network isConnected: \(isConnected)")
        }
    }
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                withAnimation(.linear){
                self.isConnected = path.status == .satisfied
                }
            }
        }
        
        monitor.start(queue: queue)
    }
}
