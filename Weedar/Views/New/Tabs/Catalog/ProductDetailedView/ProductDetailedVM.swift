//
//  ProductDetailedVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 15.03.2022.
//

import SwiftUI

class ProductDetailedVM: ObservableObject {
    
    @Published  var scrollOffset = 0.0
    
    @Published  var imageSize = 0.0
    
    @Published  var showWebLabTest = false

    @Published var quantity: Int = 1
    
    @Published var notification = UINotificationFeedbackGenerator()
    
    @Published var showImageFullScreen = false
    
    @Published var navHeight  = 0
    
    @Published var productContentInfo: [ProductContentInfoModel] = []
    
    @Published var showAR = false
    
    @Published var animProductInCart = false
    
    struct ProductContentInfoModel: Identifiable, Hashable {
        var id = UUID().uuidString
        var title: String
        var value: String
        var textColor: Color
        var bgColor: Color
    }
    
    func addProductContntInfo(title: String, value: Double, textColor: Color, bgColor: Color) {
        let val = "\(String(format: "%.0f", value))%"
        
        self.productContentInfo.append(ProductContentInfoModel(title: title, value: val, textColor: textColor, bgColor: bgColor))
    }
    
    func chageAddButtonState(){
        withAnimation(.linear(duration: 0.2)){
            animProductInCart = true
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.animProductInCart = false
            }
        }
    }
}
