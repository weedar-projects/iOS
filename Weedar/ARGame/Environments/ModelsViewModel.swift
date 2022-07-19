//
//  ModelsViewModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 19.07.2022.
//

import SwiftUI
import FirebaseFirestore

class ModelsViewModel: ObservableObject {
    @Published var models: [Model] = [Model(name: "model1", category: .test, scaleCompensation: 1.0),
                                      Model(name: "model2", category: .test, scaleCompensation: 1.0),
                                      Model(name: "model3", category: .test, scaleCompensation: 1.0)]
    
    private let db = Firestore.firestore()
    
    func fetchData() {
        db.collection("models").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Firestore: No documents.")
                return
            }
            
            self.models = documents.map { (queryDocumentSnapshot) -> Model in
                let data = queryDocumentSnapshot.data()
                
                let name = data["name"] as? String ?? ""
                let categoryText = data["category"] as? String ?? ""
                let category = ModelCategory(rawValue: categoryText) ?? .test
                let scaleCompensation = data["scaleCompensation"] as? Double ?? 1.0
                
                return Model(name: name, category: category, scaleCompensation: Float(scaleCompensation))
            }
        }
    }
    
    func clearModelEntitiesFromMemory() {
        for model in models {
            model.modelEntity = nil
        }
    }
}
