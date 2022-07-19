//
//  ARGameMainView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 19.07.2022.
//

import SwiftUI


struct AR_FurnitureApp: App {
    @StateObject var sessionSettings = SessionSettings()
    @StateObject var placementSettings = PlacementSettings()
    @StateObject var sceneManager = SceneManager()
    @StateObject var modelsViewModel = ModelsViewModel()
    @StateObject var modelDeletionManager = ModelDeletionManager()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionSettings)
                .environmentObject(placementSettings)
                .environmentObject(sceneManager)
                .environmentObject(modelsViewModel)
                .environmentObject(modelDeletionManager)
        }
    }
}
