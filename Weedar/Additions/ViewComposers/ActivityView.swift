//
//  ActivityView.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 17.09.2021.
//

import SwiftUI

struct ActivityView: View {
    // MARK: - Properties
    @State var status: ActivityStatus = .load
    @State var isAnimating: Bool = false
    
    
    // MARK: - View
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
            
            // Loader
            ZStack {
                // Bckground color
                Color(status.rawValue)
                    .ignoresSafeArea()
                
                VStack {
                    if status == .load {
                        Image("activity-loader")
                            .frame(width: 48, height: 48, alignment: .center)
                            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                            .animation(Animation.linear(duration: 1.3).repeatForever(autoreverses: false))
                            .onAppear() {
                                self.isAnimating = true
                            }
                    }
                    
                    if status == .success {
                        Image("activity-check")
                            .frame(width: 48, height: 48, alignment: .center)
                            .foregroundColor(Color.lightOnSurfaceA.opacity(1.0))
                    }
                } // VStack
                .padding(.all, 16)
            } // ZStack
            .frame(width: 72, height: 72, alignment: .center)
            .cornerRadius(16)
        } // ZStack
        .ignoresSafeArea()
    } // body
}


// MARK: - PreviewProvider
#if DEBUG
struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
#endif
