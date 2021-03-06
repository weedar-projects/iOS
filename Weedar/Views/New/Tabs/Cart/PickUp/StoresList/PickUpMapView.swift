//
//  PickUpMapView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.06.2022.
//

import SwiftUI
import MapKit
import CoreLocation

struct PickUpMapView: View {
    @StateObject var rootVM: PickUpRootVM

    
    var body: some View{
        VStack{
            Map(coordinateRegion: $rootVM.mapRegion, annotationItems: rootVM.availableStores) { store in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: store.latitudeCoordinate, longitude: store.longitudeCoordinate)) {
                    if store.isMyLocation{
                        ZStack{
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(Color.col_pink_main)
                        }
                    }else{
                        ZStack{
                            Image(store.id == rootVM.selectedStore?.id ?? 0 ? "selected_mapMarker_icon" : "mapMarker_icon")
                                .offset(y: store.id == rootVM.selectedStore?.id ?? 0 ? -22 : -11)
                                .onTapGesture {
                                    rootVM.selectedStore = store
                                }
                        }
                    }
                }

            }
            
            .frame(height: 338)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)
            
            if let store = rootVM.selectedStore{
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
                    withAnimation {
                        rootVM.showStoreInfo = true
                    }
                }
            }
        }
    }
}
