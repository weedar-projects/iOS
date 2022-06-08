//
//  ProductCartRowVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.03.2022.
//

import SwiftUI

class ProductCartRowVM: ObservableObject {
 
    @Published var offset: CGFloat = 0
    @Published var animationOffset: CGFloat = 0
    @Published var isSwiped: Bool = false
    
    let itemViewHeight: CGFloat = 113
    
    
    //swipe gesture
    func onChanged(value: DragGesture.Value){
        print(value.translation.width)
        if value.translation.width < 0 && offset > -91{
            
            if isSwiped{
                offset = value.translation.width - 90
            }
            else{
                offset = value.translation.width
            }
        }
    }
    
    func onEnd(value: DragGesture.Value){
        
        withAnimation(.easeOut){
            if value.translation.width < 0{
                //swipe to show button
                if -offset > 50{
                    // updating is Swipng...
                    isSwiped = true
                    offset = -90
                }
                else{
                    isSwiped = false
                    offset = 0
                }
            }
            else{
                isSwiped = false
                offset = 0
            }
        }
    }
}
