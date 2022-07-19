//
//  ModelDeletionManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 19.07.2022.
//

import SwiftUI
import RealityKit

class ModelDeletionManager: ObservableObject {
    @Published var entitySelectedForDeletion: ModelEntity? = nil {
        willSet(newValue) {
            if self.entitySelectedForDeletion == nil, let newlySelectedModelEntity = newValue {
                
                // Selecting new entitySelectedForDeletion, no prior selection
                print("Selecting new entitySelectedForDeletion, no prior selection.")
                
                // Set newlySelectedModelEntity
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            } else if let previouslySelectedModelEntity = self.entitySelectedForDeletion, let newlySelectedModelEntity = newValue {
                
                // Selecting new entitySelectedForDeletion, had a prior selection
                print("Selecting new entitySelectedForDeletion, had a prior selection.")

                // Clear previouslySelectedModelEntity
                previouslySelectedModelEntity.modelDebugOptions = nil
                
                // Set newlySelectedModelEntity
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            } else if newValue == nil {
                
                // Clearing entitySelectedForDeletion
                print("Clearing entitySelectedForDeletion.")
                self.entitySelectedForDeletion?.modelDebugOptions = nil
            }
        }
    }
}
