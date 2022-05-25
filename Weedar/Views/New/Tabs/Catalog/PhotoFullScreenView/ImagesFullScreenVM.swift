//
//  PhotoFullScreenVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 08.04.2022.
//

import SwiftUI
import Alamofire

class ImagesFullScreenVM: ObservableObject {

    // BG Opacity...
    @Published var bgOpacity: Double = 1
    @Published var quantity: Int = 1

    // Scaling....
    @Published var imageScale: CGFloat = 1
    
    @Published var imageViewerOffset: CGSize = .zero
  
    @Published var showImageFullScreen = false
    @Published var animProductInCart = false

    
    @Published var notification = UINotificationFeedbackGenerator()
    
    func onChange(value: CGSize){
        
        // updating Offset...
        imageViewerOffset = value
        
        // calculating opactity....
        let halgHeight = UIScreen.main.bounds.height / 2
        
        let progress = imageViewerOffset.height / halgHeight
        
        withAnimation(.default){
            bgOpacity = Double(1 - (progress < 0 ? -progress : progress))
        }
    }
    
    func onEnd(value: DragGesture.Value){
        
        withAnimation(.easeInOut){
            
            var translation = value.translation.height
            
            if translation < 0{
                translation = -translation
            }
            
            if translation < 250{
                imageViewerOffset = .zero
                bgOpacity = 1
            }
            else{
                showImageFullScreen.toggle()
                
                imageViewerOffset = .zero
                bgOpacity = 1
            }
        }
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
