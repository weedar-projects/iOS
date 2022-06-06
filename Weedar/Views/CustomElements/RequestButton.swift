//
//  MainButtom.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.02.2022.
//

import SwiftUI

enum ButtonState {
    case loading
    case success
    case def
}

struct RequestButton: View {
    @Binding var state: ButtonState
    @Binding var isDisabled: Bool
  
    @State var showIcon = true
    
    @State var title: String = ""
    
    var action: () -> Void
    
    var body: some View {
        ZStack{
            HStack(spacing: 0) {
                switch state {
                case .loading:
                    LineLoaderView(progressColor: Color.col_white, bgColor: Color.white.opacity(0.05))
                        .frame(height: 4)
                        .padding(EdgeInsets(top: 0, leading: 48, bottom: 0, trailing: 48))
                case .success:
                    Image("checkmark")
                        .colorInvert()
                        .scaleEffect(0.7)
                case .def:
                    HStack{
                        Text(title.localized)
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_white)
                        
                        if showIcon{
                            Image("welcome-content-arrow-right")
                                .frame(width: 24, height: 24)
                            
                        }
                    }
                }
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.col_black.opacity(isDisabled ? 0.3 : 1))
            .cornerRadius(12)
            .onTapGesture {
                withAnimation{
                    state = .loading
                }
                action()
            }
            
        }
        .disabled(isDisabled || state == .loading)
    }
}
