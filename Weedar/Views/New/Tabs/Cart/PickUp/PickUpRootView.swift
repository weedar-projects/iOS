//
//  PickUpRootView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.06.2022.
//

import SwiftUI
import MapKit


class PickUpRootVM: ObservableObject{
    @Published var selectedTab: PickUpShopListState = .list
    @Published var selectedStore: StoreModel?
    @Published var selectedRadius = 10
    @Published var showStoreInfo = false
    
    @Published var mockupStores = [
        StoreModel(id: 1, name: "Buckingham Palace",fullAddress: "91214 Glendale, La Crescenta" ,coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
        StoreModel(id: 2, name: "Tower of London", fullAddress: "91214 Glendale, La Crescenta, Montrose",coordinate: CLLocationCoordinate2D(latitude: 51.505, longitude: -0.050)),
        StoreModel(id: 3, name: "Tower of London", fullAddress: "91214 Glendale, La Montrose",coordinate: CLLocationCoordinate2D(latitude: 51.503, longitude: -0.025)),
        StoreModel(id: 4, name: "Tower of London", fullAddress: "91214, La Crescenta, Montrose",coordinate: CLLocationCoordinate2D(latitude: 51.502, longitude: -0.090)),
        StoreModel(id: 5, name: "Tower of London", fullAddress: "91214 Glendale, Montrose",coordinate: CLLocationCoordinate2D(latitude: 51.507, longitude: -0.153))
    ]
    
    @Published var showRaduisPicker = false
}

struct PickUpRootView: View {
    @StateObject var vm = PickUpRootVM()
    
    var body: some View {
        ZStack{
            NavigationLink(isActive: $vm.showRaduisPicker) {
                GeolocationSelectView(selectedRadius: $vm.selectedRadius)
            } label: {
                Color.clear
            }.isDetailLink(false)
            Color.col_white
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                PickUpShopListPiker(selected: $vm.selectedTab)
                
                
                RadiusSelectBtn()
                    .padding(.top, 24)
                    .onTapGesture {
                        vm.showRaduisPicker = true
                    }
                
                Text("Stores available: \(vm.mockupStores.count)")
                    .textSecond()
                    .padding([.horizontal,.top], 24)
                    .hLeading()
                
                if vm.selectedTab == .list{
                    PickUpListView(rootVM: vm)
                        .transition(.fade)
                }else{
                    PickUpMapView(rootVM: vm)
                        .transition(.fade)
                }
                
                Spacer()
            }
            
            if vm.showStoreInfo{
                Color.col_black
                    .opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.fade)
                    .onTapGesture {
                        withAnimation {
                            vm.showStoreInfo = false
                        }
                    }
                
                StoreInfo(rootVM: vm)
                    .transition(.move(edge: .bottom))
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
            
            Text("Within \(vm.selectedRadius) miles")
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

struct StoreModel: Identifiable {
    let id: Int
    let name: String
    let fullAddress: String
    var coordinate: CLLocationCoordinate2D
}

enum PickUpShopListState{
    case list
    case map
}

struct PickUpListView: View {
    @StateObject var rootVM: PickUpRootVM
    
    var body: some View{
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading,spacing: 17){
                ForEach(rootVM.mockupStores){store in
                    HStack(spacing: 0){
                        Image("mapMarker_icon")
                            .scaleEffect(0.8)
                            .padding(.trailing, 8)
                            .padding(.leading, 16)
                        
                        Text(store.fullAddress)
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

struct PickUpMapView: View {
    @StateObject var rootVM: PickUpRootVM

    
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    var body: some View{
        VStack{
            Map(coordinateRegion: $mapRegion, annotationItems: rootVM.mockupStores) { store in
                MapAnnotation(coordinate: store.coordinate) {
                    ZStack{
                        Image(store.id == rootVM.selectedStore?.id ?? 0 ? "selected_mapMarker_icon" : "mapMarker_icon")
                            .offset(y: store.id == rootVM.selectedStore?.id ?? 0 ? -22 : -11)
                            .onTapGesture {
                                rootVM.selectedStore = store
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

                Text(store.fullAddress)
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

struct PickUpShopListPiker: View {
    
    @Binding var selected: PickUpShopListState
    
    
    var body: some View {
        HStack(spacing: 0){
            Text("See list")
                .textCustom(.coreSansC65Bold, 16, selected == .list ? Color.col_text_white : Color.col_text_main)
                .frame(width: (getRect().width / 2 - 24), height: 44)
                .background(Color.col_white.opacity(0.01))
                .onTapGesture {
                    withAnimation {
                        selected = .list
                    }
                }
            
            Text("See on map")
                .textCustom(.coreSansC65Bold, 16, selected == .map ? Color.col_text_white : Color.col_text_main)
                .frame(width: (getRect().width / 2 - 24), height: 44)
                .background(Color.col_white.opacity(0.01))
                .onTapGesture {
                    withAnimation {
                        selected = .map
                    }
                    
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
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
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
                mode.wrappedValue.dismiss()
            }
        }
        .padding(.horizontal, 24)
        .navBarSettings("Geolocation")
    }
}

struct StoreInfo: View{
    
    @StateObject var rootVM: PickUpRootVM
    
    var body: some View{
        if let store = rootVM.selectedStore {
            VStack{
                
                Spacer()
                
                ZStack{
                    Color.col_white.cornerRadius(radius: 12, corners: [.topLeft,.topRight])
                    
                    Button(action: {
                        withAnimation {
                            rootVM.showStoreInfo = false
                        }
                    }, label: {
                        Image("xmark")
                            .resizable()
                            .frame(width: 12, height: 12, alignment: .center)
                    })
                    .vTop()
                    .hTrailing()
                    .padding(19)
                    
                    VStack{
                        Text(store.fullAddress)
                            .textCustom(.coreSansC45Regular, 28, Color.col_text_main)
                            .hLeading()
                            .padding(24)
                        
                        VStack(alignment: .leading, spacing: 0){
                            Row(icon: "calendar_icon", value: "Monday - Sunday")
                            CustomDivider()
                            Row(icon: "clock_icon", value: "10AM - 8PM")
                            CustomDivider()
                            Row(icon: "phone_icon", value: format(phone: "3414231231"))
                        }
                        .background(
                            RadialGradient(colors: [Color.col_gradient_blue_second,
                                                    Color.col_gradient_blue_first],
                                           center: .center,
                                           startRadius: 0,
                                           endRadius: 220)
                            .opacity(0.25)
                            .clipShape(CustomCorner(corners: .allCorners,
                                                    radius: 12))
                        )
                        .padding(.horizontal, 24)
                        
                        
                        ZStack{
                            RadialGradient(colors: [Color.col_gradient_blue_second,
                                                    Color.col_gradient_blue_first],
                                           center: .center,
                                           startRadius: 0,
                                           endRadius: 220)
                            .opacity(0.25)
                            .clipShape(CustomCorner(corners: .allCorners,
                                                    radius: 12))
                            .frame(height: 48)
                            
                            Text("Directions")
                                .textCustom(.coreSansC55Medium, 16, Color.col_blue_main)
                        }
                        .onTapGesture {
                            
                        }
                        .padding(24)
                        
                        MainButton(title: "Done") {
                            
                        }
                        .padding([.bottom,.horizontal],24)
                    }
                }
                .frame(height: 458)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    @ViewBuilder
    func Row(icon: String, value: String) -> some View {
        HStack(spacing: 0){
            Image(icon)
                .padding(.horizontal, 18)
            
            Text(value)
                .textDefault()
        }
        .frame(height: 48)
    }
    
    func format(phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in "+X (XXX) XXX-XXXXXX" where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
}
