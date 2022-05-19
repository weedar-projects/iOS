//
//  ARCategoryView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ARCategoryView: View {
    
    @State private var title = "AR catalog"
    @State private var descreption = "Experience products in \nthe comfort of your \nown home."
    
    @EnvironmentObject var tabBarManager: TabBarManager
    
    @StateObject var localModels: ARModelsManager
    
    @State var progress: Float = 0
    @State var animation = true
    var body: some View{
        ZStack{
            Color("col_catalog_bg")
                .cornerRadius(16)
                .frame(height: 153)
            
            VStack(alignment: .leading, spacing: 9){
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .hLeading()
                    .padding(.top, 8)
                    .foregroundColor(Color.white)
                
                Text(descreption)
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.7))
                    .hLeading()
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2.8)
            }
            .padding(.leading,25)
            .padding(.vertical, 34)
            .hLeading()
            
            // Bundle (not Asset Catalog)
            AnimatedImage(name: "catalog_ar_gif.gif", isAnimating: $animation)
                .resizable()
                .frame(width: 188 - 30, height: 163 - 30)
                .hTrailing()
        }
        .padding(.horizontal, 16)
        .onTapGesture {
            print("allmodels: \(localModels.allModelCount) : currentmodels: \(localModels.currentLoadedModel)")
            if localModels.currentLoadedModel >= localModels.allModelCount{
                tabBarManager.hideTracker()
                tabBarManager.showARView.toggle()
            }
        }
        .overlay(
            ZStack{
                Color.col_black
                    .opacity(0.6)
                    .cornerRadius(16)
                    .padding(.horizontal)
                
                VStack{
                    Image("Single_Logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 54)
                    
                    Text("\(String(format: "%.0f",  (progress * 100)))%")
                        .textCustom(.coreSansC45Regular, 10, Color.col_white)
                    
                    CustomProgressBar(value: $progress)
                        .frame(width: 220)
                }
            }
                .opacity(localModels.currentLoadedModel >= localModels.allModelCount ? 0 : 1)
                .onChange(of: localModels.currentLoadedModel, perform: { currentLoaded in
                    progress = Float(currentLoaded) / Float(localModels.allModelCount)
                })
                .onAppear(perform: {
                    progress = Float(localModels.currentLoadedModel) / Float(localModels.allModelCount)
                })
        )
    }
}
