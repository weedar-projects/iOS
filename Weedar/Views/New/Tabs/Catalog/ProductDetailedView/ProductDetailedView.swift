//
//  ProductDetailedView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 15.03.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import Amplitude

struct ProductDetailedView: View {
    @StateObject var vm  = ProductDetailedVM()
    
    @State var product: ProductModel
    
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var body: some View {
        ZStack{
            
            NavigationLink(isActive: $vm.showAR) {
                HomeView()
                    .onAppear {
                        tabBarManager.show()
                    }
                    .onDisappear {
                        tabBarManager.hide()
                    }
            } label: {
                EmptyView()
            }
            
            Color.white
            
            HeaderView()
                .onTapGesture {
                    vm.showImageFullScreen.toggle()
                }
                .animation(.none, value: true)
            
            ProductDetailedBodyView(imageSize: $vm.imageSize, scrollOffset: $vm.scrollOffset) {
                
                //category tree
                HStack{
                    //category name
                    Text(product.type.name)
                        .textCustom(.coreSansC45Regular, 12, Color.col_text_second)
                    
                    //separate circle
                    Circle()
                        .fill(Color.col_text_second)
                        .frame(width: 4, height: 4)
                    
                    //brand name
                    Text(product.brand.name ?? "")
                        .textCustom(.coreSansC45Regular, 12, Color.col_text_second)
                }
                .padding([.top, .leading], 24)
                
                //product name
                Text(product.name)
                    .textCustom(.coreSansC45Regular, 28, Color.col_text_main)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                //information and AR button
                InformationAndArButtonView()
                
                //Price and gramms
                PriceAndGramsView()
                
                //percents
                ProductСontentInfoView()
                
                //effects
                ProductEffectsView()
                
                //Quantity View
                QuantityView()
                
                AddToCartButton()
                    .padding(.top, 25)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 200)
            }
            
            if vm.showImageFullScreen{
                ImagesFullScreenView(imageLink: product.imageLink,product: product ,showImageFullScreen: $vm.showImageFullScreen)
                    .transition(.fade)
                
            }
        }
        .onAppear{
            //add information values
            vm.productContentInfo.removeAll()
            vm.addProductContntInfo(title: "THC", value: product.thc, textColor: Color.col_pink_main, bgColor: Color.col_red_second)
            vm.addProductContntInfo(title: "CBD", value: product.cbd, textColor: Color.col_blue_main, bgColor: Color.col_blue_second)
            vm.addProductContntInfo(title: "Canabioids", value: product.totalCannabinoids, textColor: Color.col_green_main, bgColor: Color.col_green_second)
        }
        .navBarSettings(backBtnIsHidden: vm.showImageFullScreen)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    cartManager.clearAllProductCart()
                } label: {
                    Button {
                        withAnimation {
                            vm.showImageFullScreen.toggle()
                        }
                    } label: {
                        Image("xmark")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .colorInvert()
                            .padding(.trailing, 10)
                    }
                }
                .opacity(vm.showImageFullScreen ? 1 : 0)
            }
        }
        .sheet(isPresented: $vm.showWebLabTest) {
            WebView(urlType: URLs.customURL(urlString: product.labTestLink ?? "", title: product.name))
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    @ViewBuilder
    func HeaderView() ->some View {
        
        VStack() {
            GeometryReader { geo in
                
                ImageUrlView(url: "\(BaseRepository().baseURL)/img/" + product.imageLink, width: geo.size.width + CGFloat(vm.imageSize))
                    .overlay(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0),Color.white.opacity(0),  Color.clear]),
                                            startPoint: .top, endPoint: .bottom)
                                .frame(height: geo.size.width)
                                .offset(y: -geo.size.width / 2 + 50))
                    .frame(alignment: .center)
                    .offset(x: CGFloat(-vm.imageSize/2))
                
            }
        }
        .ignoresSafeArea(.all)
    }
    
    @ViewBuilder
    func TopGradient() -> some View {
        VStack{
            LinearGradient(gradient: Gradient(colors: [Color.col_white.opacity(0.9),
                                                       Color.col_white.opacity(0.2),
                                                       Color.clear]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 116)
                .zIndex(3)
            Spacer()
        }
        .onTapGesture {
            vm.showImageFullScreen = true
        }
    }
    
    @ViewBuilder
    func InformationAndArButtonView() -> some View {
        HStack{
            //information
            HStack(alignment: .top, spacing: 8){
                
                //THC
                Text(product.strain.name)
                    .textCustom(.coreSansC65Bold, 12, Color.col_blue_main)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.col_blue_second.cornerRadius(12))
                
                //Labtest button
                
                ZStack{
                    HStack{
                        //icon
                        Image("labtest")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 13)
                        
                        Text("Lab test")
                            .textCustom(.coreSansC65Bold, 12, Color.col_green_main)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.col_green_second.cornerRadius(12))
                    // set black-white
                    .saturation(product.labTestLink?.isEmpty ?? true ? 0 : 1)
                }
                .disabled(product.labTestLink?.isEmpty ?? true)
                .onTapGesture {
                    vm.showWebLabTest.toggle()
                }
            }
            .vTop()
            
            Spacer()
            
            //Button
            Image("ar_button")
                .resizable()
                .frame(width: 72, height: 72)
                .onTapGesture {
                    tabBarManager.hideTracker()
                    vm.showAR.toggle()
                    if UserDefaults.standard.bool(forKey: "EnableTracking"){

                    Amplitude.instance().logEvent("product_card_ar", withEventProperties: ["category" : product.type.name,
                                                                                           "product_id" : product.id,
                                                                                           "product_qty" : vm.quantity,
                                                                                           "product_price" : product.price.formattedString(format: .percent)])
                    }
                }
            
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    func PriceAndGramsView() -> some View {
        HStack{
            Text("$\(product.price.percentsString())")
                .textCustom(.coreSansC65Bold, 20, Color.col_purple_main)
            
            Text("\(product.gramWeight.formattedString(format: .gramm))g / \(product.ounceWeight.formattedString(format: .ounce))oz")
                .textSecond()
        }
        .padding(.leading, 24)
    }
    
    @ViewBuilder
    func ProductСontentInfoView() -> some View {
        HStack{
            ForEach(vm.productContentInfo, id: \.self){ info in
                //percents
                
                VStack(spacing: 7){
                    Text(info.value)
                        .textCustom(.coreSansC45Regular, 28, info.textColor)
                    
                    Text(info.title)
                        .textCustom(.coreSansC45Regular, 12, info.textColor)
                }
                .padding([.leading, .top, .trailing])
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity)
                .background(info.bgColor.cornerRadius(12))
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    func ProductEffectsView() -> some View {
        Text("Effects")
            .textSecond()
            .padding(.leading , 36)
            .padding(.top, 16)
        
        //effects scroll view
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15){
                ForEach(product.effects) {effect in
                    Text("\(effect.emoji) \(effect.name)")
                        .textDefault()
                        .padding(12)
                        .overlay(
                            //color
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.col_borders, lineWidth: 2)
                                .frame(height: 46)
                        )
                        .frame(height: 48)
                }
            }
            .padding(.horizontal, 24)
            
        }
        .padding(.top, 5)
    }
    
    @ViewBuilder
    func QuantityView() -> some View {
        Text("Quantity")
            .textSecond()
            .padding(.leading , 36)
            .padding(.top, 16)
        
        HStack{
            
            
            ZStack{
                Text("-")
                    .textCustom(.coreSansC45Regular, 32, Color.col_text_second)
                    .padding([.trailing,.top,.bottom], 10)
                    .padding(.leading, 17)
                    .offset(y: 2)
            }
            .onTapGesture {
                vm.quantity -= 1
            }
            
            Spacer()
            
            Text("\(vm.quantity)")
                .textCustom(.coreSansC45Regular, 16, Color.col_text_main)
            
            Spacer()
            
            
            
            ZStack{
                Text("+")
                    .textCustom(.coreSansC45Regular, 32, Color.col_text_second)
                    .padding([.leading,.top,.bottom], 10)
                    .padding(.trailing, 17)
                    .offset(y: 2)
            }
            .onTapGesture {
                vm.quantity += 1
            }
            .onChange(of: vm.quantity) { newValue in
                if newValue <= 1 {
                    vm.quantity = 1
                }
            }
        }
        .overlay(
            //border
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.col_borders, lineWidth: 2)
                .frame(height: 46)
        )
        .frame(height: 48)
        .padding(.top, 5)
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    func AddToCartButton() -> some View {

        ZStack{
            HStack{
                Image("checkmark")
                    .resizable()
                    .frame(width: 13, height: 13)
                    .foregroundColor(Color.col_white)
                
                Text("Added to cart")
                    .textCustom(.coreSansC65Bold, 16,Color.col_white)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.col_green_main)
            .cornerRadius(12)
            .opacity(vm.animProductInCart ? 1 : 0)
            
            HStack{
                Image("cart")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color.col_text_main)
                
                Text( "Add to cart - $\((product.price * Double(vm.quantity)).formattedString(format: .percent))")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.col_yellow_main)
            .cornerRadius(12)
            .opacity(vm.animProductInCart ? 0 : 1)
        }
        .onTapGesture {
            vm.notification.notificationOccurred(.success)
            cartManager.productQuantityInCart(productId: product.id, quantity: .custom(vm.quantity))
            if UserDefaults.standard.bool(forKey: "EnableTracking"){

            Amplitude.instance().logEvent("add_cart_prod_card", withEventProperties: ["category" : product.type.name,
                                                                                      "product_id" : product.id,
                                                                                      "product_qty" : vm.quantity,
                                                                                      "product_price" : product.price.formattedString(format: .percent)])
            }
            vm.chageAddButtonState()
        }.disabled(vm.animProductInCart)
    }
    
}
