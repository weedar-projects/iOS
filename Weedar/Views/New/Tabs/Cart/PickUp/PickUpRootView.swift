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
    @State var selectedLocation: Location?
    @State var selectedRadius = 10
    
    @State var showRaduisPicker = false
    
    var body: some View {
        ZStack{
            
            NavigationLink(isActive: $showRaduisPicker) {
                GeolocationSelectView(selectedRadius: $selectedRadius)
            } label: {
                Color.clear
            }

            Color.col_white
            
            VStack{
                PickUpShopListPiker(selected: $selectedTab)
                
    
                RadiusSelectBtn()
                    .padding(.top, 24)
                    .onTapGesture {
                        showRaduisPicker = true
                    }
                Text("Stores available: 4")
                    .textSecond()
                    .padding([.horizontal,.top], 24)
                    .hLeading()
                
                PickUpMapView(selectedLocation: $selectedLocation)
                    
                
                Spacer()
            }
        }
        .navBarSettings("Choose store")
    }
    
    
    @ViewBuilder
    func RadiusSelectBtn() -> some View{
        
        HStack(spacing: 0){
            Image("mapMarker_icon")
                .scaleEffect(0.8)
                .padding(.leading , 16)
            
            Text("Within \(selectedRadius) miles")
                .textCustom(.coreSansC45Regular, 16, Color.col_text_main)
            Spacer()
            Image("arrowRight")
                .padding(.trailing , 16)
        }
        .padding(.horizontal, 24)
        .frame(height: 48)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
            .strokeBorder()
            .frame(height: 48)
            .foregroundColor(Color.col_gray_main)
            .padding(.horizontal, 24)
        )
        
    }
}

struct PickUpRootView_Previews: PreviewProvider {
    static var previews: some View {
        PickUpRootView()
    }
}

struct Location: Identifiable {
    let id: Int
    let name: String
    let coordinate: CLLocationCoordinate2D
}

enum PickUpShopListState{
    case list
    case map
}


struct PickUpMapView: View {
    @Binding var selectedLocation: Location?
    @State var locations = [
        Location(id: 1, name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
        Location(id: 2, name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
    ]
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    var body: some View{
        Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                ZStack{
                    Image(location.id == selectedLocation?.id ?? 0 ? "selected_mapMarker_icon" : "mapMarker_icon")
                        .offset(y: location.id == selectedLocation?.id ?? 0 ? -22 : -11)
                        .onTapGesture {
                            self.selectedLocation = location
                        }
                }
            }
        }
        .frame(height: 338)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 24)
        
    }
}

struct PickUpShopListPiker: View {
    
    @Binding var selected: PickUpShopListState
    
    
    var body: some View {
            HStack(spacing: 0){
                Text("See list")
                    .textCustom(.coreSansC65Bold, 16, selected == .list ? Color.col_text_white : Color.col_text_main)
                    .frame(width: (getRect().width / 2 - 24), height: 44)
                    .background(Color.col_white.opacity(0.01))
                    .onTapGesture {
                        selected = .list
                    }
                
                Text("See on map")
                    .textCustom(.coreSansC65Bold, 16, selected == .map ? Color.col_text_white : Color.col_text_main)
                    .frame(width: (getRect().width / 2 - 24), height: 44)
                    .background(Color.col_white.opacity(0.01))
                    .onTapGesture {
                        selected = .map
                    }
            }
            .frame(maxWidth: .infinity)
            
            .background(
                HStack{
                    Color.col_black
                        .frame(width: (getRect().width / 2 - 24), height: 44)
                        .cornerRadius(radius: 12, corners: selected == .map ? [.bottomRight, .topRight] : [.bottomLeft, .topLeft])
                        .animation(.interactiveSpring(response: 0.15,
                                                      dampingFraction: 0.65,
                                                      blendDuration: 1.5),
                                   value: selected)
                        .offset(x: selected == .map ? (getRect().width / 2 - 24) : 0)
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



struct GeolocationSelectView: View {
    @Binding var selectedRadius: Int
    
    var radiusValues = [5, 10, 15, 25]
    
    var body: some View{
        VStack(alignment: .leading){
            ForEach(radiusValues, id: \.self) { value in
                HStack{
                    Image("location_icon")
                        .opacity(selectedRadius == value ? 1 : 0.22)
                        
                    Text("Within \(value) miles")
                        .textCustom(selectedRadius == value ? .coreSansC55Medium : .coreSansC45Regular, 16, Color.col_text_main)
                    
                    Spacer()
                    
                    ZStack{
                        RadialGradient(colors: [Color.col_gradient_green_second,
                                                Color.col_gradient_green_first],
                                       center: .center,
                                       startRadius: 0,
                                       endRadius: 25)
                        Image("checkmark")
                                    .resizable()
                                    .foregroundColor(Color.col_black)
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                    }
                    .clipShape(Circle())
                    .frame(width: 28, height: 28)
                    .opacity(selectedRadius == value ? 1 : 0)
                }
                .frame(height: 50)
                .background(Color.col_white)
                .onTapGesture {
                    selectedRadius = value
                }
                
                CustomDivider()
                    .opacity(value == radiusValues.last ? 0 : 1)
            }
            
            Spacer()
            
            MainButton(title: "Comfirm") {
                
            }
        }
        .padding(.horizontal, 24)
        .navBarSettings("Geolocation")
    }
}

//struct GeolocationSelectView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeolocationSelectView()
//    }
//}
