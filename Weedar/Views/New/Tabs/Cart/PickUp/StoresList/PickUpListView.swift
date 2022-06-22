//
//  PickUpListView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.06.2022.
//

import SwiftUI

struct PickUpListView: View {
    @StateObject var rootVM: PickUpRootVM
    
    var body: some View{
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading,spacing: 17){
                ForEach(rootVM.avaibleStores){store in
                    HStack(spacing: 0){
                        Image("mapMarker_icon")
                            .scaleEffect(0.8)
                            .padding(.trailing, 8)
                            .padding(.leading, 16)
                        
                        Text(store.address)
                            .textDefault()
                            .hLeading()
                            .frame(maxWidth: .infinity)
                            .padding(.trailing, 20)
                        
                        Image("arrowRight")
                            .padding(.trailing, 16)
                    }
                    .background(
                        RadialGradient(colors: [Color.col_gradient_blue_second,
                                                Color.col_gradient_blue_first],
                                       center: .center,
                                       startRadius: 0,
                                       endRadius: 220)
                        .frame(height: 69)
                        .clipShape(CustomCorner(corners: .allCorners, radius: 12))
                        .opacity(0.25)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 69)
                    .padding(.horizontal, 24)
                    .onTapGesture {
                        rootVM.selectedStore = store
                        withAnimation {
                            rootVM.showStoreInfo = true
                        }
                    }
                }
            }
        }
    }
}
