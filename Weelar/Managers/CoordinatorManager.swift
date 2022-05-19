//
//  CoordinatorManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 16.03.2022.
//

import SwiftUI

enum RootCoordinatorViews{
    case auth
    case registerSetps
    case main
    
}

class CoordinatorViewManager: ObservableObject {
    @Published var currentRootView: RootCoordinatorViews = .main{
        didSet{
            print("CURRENT ROOT VIEW: \(currentRootView)")
        }
    }
}
