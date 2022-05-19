//
//  LoadingDocumentCenterView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 12.04.2022.
//

import SwiftUI

struct LoadingDocumentCenterView: View {
    var body: some View {
        
            LazyVStack{
                ShimmerView()
                    .cornerRadius(16)
                    .frame(height: 68)
                    .hLeading()
                    
                ShimmerView()
                    .cornerRadius(16)
                    .frame(height: 38)
                    .hLeading()
                    
                
                ShimmerView()
                    .cornerRadius(16)
                    .frame(width: 100,height: 17)
                    .padding(.top)
                    .padding(.leading, 24)
                    .hLeading()
                
                
                ShimmerView()
                    .cornerRadius(16)
                    .frame(height: 158)
                
                ShimmerView()
                    .cornerRadius(21)
                    .frame(height: 42)
                    .padding(.top)
                
                ShimmerView()
                    .cornerRadius(16)
                    .frame(height: 100)
                
                ShimmerView()
                    .cornerRadius(16)
                    .frame(width: 100,height: 17)
                    .padding(.top)
                    .padding(.leading, 24)
                    .hLeading()
                
                ShimmerView()
                    .cornerRadius(21)
                    .frame(height: 42)
                    .padding(.top, 25)
                
            }
            .padding(.horizontal, 24)
            
            
    }
}

struct LoadingDocumentCenterView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingDocumentCenterView()
    }
}
