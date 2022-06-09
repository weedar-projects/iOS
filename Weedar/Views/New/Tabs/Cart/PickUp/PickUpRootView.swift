//
//  PickUpRootView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.06.2022.
//

import SwiftUI
import MapKit

struct PickUpRootView: View {
    @State var selectedTab: PickUpShopListState = .list
    
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))

    
    let locations = [
        Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
        Location(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
    ]
    
    var body: some View {
        ZStack{
            VStack{
                PickUpShopListPiker(selected: $selectedTab)
                
                Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        Circle()
                            .stroke(.red, lineWidth: 3)
                            .frame(width: 44, height: 44)
                    }
                }
                .vTop()
                
                Spacer()
                
            }
        }
        .navBarSettings("Choose store")
    }
}

struct PickUpRootView_Previews: PreviewProvider {
    static var previews: some View {
        PickUpRootView()
    }
}

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

enum PickUpShopListState{
    case list
    case map
}


struct PickUpShopListPiker: View {
    
    @Binding var selected: PickUpShopListState
    private 
    var body: some View {
            HStack(spacing: 0){
                Text("See list")
                    .textCustom(.coreSansC65Bold, 16, selected == .list ? Color.col_text_white : Color.col_text_main)
                    .frame(width: (width / 2) - 24, height: 44)
                    .background(Color.col_white.opacity(0.01))
                    .onTapGesture {
                        selected = .list
                    }
                
                Text("See on map")
                    .textCustom(.coreSansC65Bold, 16, selected == .map ? Color.col_text_white : Color.col_text_main)
                    .frame(width: (width / 2) - 24, height: 44)
                    .background(Color.col_white.opacity(0.01))
                    .onTapGesture {
                        selected = .map
                    }
            }
            .frame(maxWidth: .infinity)
            
            .background(
                HStack{
                    Color.col_black
                        .frame(width: (width / 2) - 24, height: 44)
                        .cornerRadius(radius: 12, corners: selected == .map ? [.bottomRight, .topRight] : [.bottomLeft, .topLeft])
                        .animation(.interactiveSpring(response: 0.15,
                                                      dampingFraction: 0.65,
                                                      blendDuration: 1.5),
                                   value: selected)
                        .offset(x: selected == .map ? (width / 2) - 24 : 0)
                        .hLeading()
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder()
                    .foregroundColor(Color.col_borders)
                
            )
            .padding(.horizontal, 24)
            
        }
    }
}
