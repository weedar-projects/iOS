//
//  PlacementSettings.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 19.07.2022.
//

import SwiftUI
import RealityKit
import Combine
import ARKit

struct ModelAnchor {
    var model: Model
    var anchor: ARAnchor?
}

class PlacementSettings: ObservableObject {
    @Published var selectedModel: Model? = nil {
        willSet(newValue) {
            print("Setting selectedModel to \(String(describing: newValue?.name)).")
        }
    }
    @Published var recentlyPlaced: [Model] = [] // NOTE: Last element is most recent
    var modelsConfirmedForPlacement: [ModelAnchor] = []
    var sceneObserver: Cancellable?
}
