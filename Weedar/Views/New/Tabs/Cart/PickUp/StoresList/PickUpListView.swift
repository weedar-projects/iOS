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
            ZStack{
                VStack(alignment: .leading,spacing: 17){
                    ForEach(rootVM.availableStoresList.sorted(by: ({$0.distance < $1.distance}))){store in
                        HStack(spacing: 0){
                            Image("mapMarker_icon")
                                .scaleEffect(0.8)
                                .padding(.trailing, 8)
                                .padding(.leading, 16)
                            
                            VStack{
                                Spacer()
                                Text(store.address)
                                    .textDefault()
                                    .hLeading()
                                    .frame(maxWidth: .infinity)
                                    .padding(.trailing, 20)
                                
                                Text("\(store.distance.formattedString(format: .miles)) miles from me")
                                    .textCustom(.coreSansC45Regular, 10, Color.col_text_second.opacity(0.8))
                                    .hLeading()
                                    .padding(.top, 1)
                                    .padding(.bottom, 4)
                            }
                            .frame(height: 69)
                            
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
                VStack{
                    Image("productsnotfound")
                        .resizable()
                        .frame(width: 109, height: 109)
                    
                    Text("No stores found.")
                        .textDefault()
                        .padding(.top, 18)
                }
                .ignoresSafeArea(.keyboard, edges: .all)
                .padding(.top,48)
                .opacity(rootVM.emptyStores ? 1 : 0)
            }.onChange(of: rootVM.availableStores.count) { newValue in
                rootVM.emptyStores = newValue == 0 ? true : false
            }
        }
    }
}
