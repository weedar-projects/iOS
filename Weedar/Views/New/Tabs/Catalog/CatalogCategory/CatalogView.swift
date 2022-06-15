//
//  CatalogView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 17.03.2022.
//

import SwiftUI
import Amplitude

struct CatalogView: MainLoadViewProtocol {
    
    @ObservedObject var vm = CatalogVM()
        
    @EnvironmentObject var tabBarManager: TabBarManager
    
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    
    @EnvironmentObject var networkConnection: NetworkConnection
    
    @EnvironmentObject var sessionManager: SessionManager
    
    @ObservedObject var localModels: ARModelsManager
    
    @State var showLoader: Bool = true
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var content: some View {
 
            NavigationView{
                ZStack{
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack{
                        //AR Catalog view
                        NavigationLink(isActive: $tabBarManager.showARView) {
                            HomeView()
                                .onAppear {
                                    if UserDefaults.standard.bool(forKey: "EnableTracking"){
                                        print("worktraking")
                                    Amplitude.instance().logEvent("select_catalog", withEventProperties: ["item_catalog" : "AR Catalog"])
                                    }
                                }
                        } label: {
                            EmptyView()
                        }
                        
                        Color.white
                        
                    VStack(spacing: 8){
                        
                        ARCategoryView(localModels: localModels)
                        
                        //Category from API
                            ForEach(vm.categories.filter {
                                $0.itemsCount > 0
                            }, id: \.self)
                            { category in
                                NavigationLink {
                                    CatalogProductsListView(category: category)
                                        .onAppear {
                                            if UserDefaults.standard.bool(forKey: "EnableTracking"){

                                            Amplitude.instance().logEvent("select_catalog", withEventProperties: ["item_catalog" : category.name])
                                            }
                                        }
                                } label: {
                                    SmallCategoryView(category: category)
                                }
                                .isDetailLink(false)
                                .padding(.horizontal, 16)
                            }
                        
                        //NFT Coming soon
                        Image("specialDrop")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 153)
                            .cornerRadius(16)
                            .onTapGesture {
                                vm.showWebView.toggle()
                                if UserDefaults.standard.bool(forKey: "EnableTracking"){

                                Amplitude.instance().logEvent("select_catalog", withEventProperties: ["item_catalog" : "Coming soon"])
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 25)
                        
                                
                    }
                    .padding(.bottom, tabBarManager.showOrderTracker ? 95 : 0)
                    .padding(.bottom, isSmallIPhone() ? 40 : 0)
                    .padding(.top, 6)
            
                    }
                }
                .navigationTitle("Catalog")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $vm.showWebView, content: {
                    WebViewFullSize(urlType: .customURL(urlString: "https://www.weedar.io/weedar-nft", title: ""))
                })
                .onUIKitAppear {
                    tabBarManager.showTracker()
                    tabBarManager.show()
                }
                .onAppear {
                    appDelegate.requestAuthorization()
                    
                }
                    if vm.showDiscountAlert{
                        ZStack{
                            Color.col_black.opacity(0.7).edgesIgnoringSafeArea(.all)
                            DiscountBanner(showAlert: $vm.showDiscountAlert)
                                .padding(.bottom, 20)
                                .padding(.bottom, getSafeArea().top)
                        }
                    }
                }
            }
            .id(tabBarManager.navigationIds[0])
            .onChange(of: tabBarManager.showARView) { newValue in
                orderTrackerManager.needToShow = !newValue
            }
        
            .onChange(of: networkConnection.isConnected) { isConnected in
                if isConnected{
                    self.showLoader = true
                }
            }
            .onAppear {
                sessionManager.userData { user in
                    vm.showDiscountAlert = user.showDiscountBanner
                }
            }
    }
    
    var loader: some View{
        LoadingScreenCatalogView()
            .onAppear(perform: {
                if networkConnection.isConnected{
                    if vm.categories.isEmpty{
                        self.vm.loadCategories { val in
                            self.vm.fetchProducts {
//                                self.localModels.fetchProducts {
//                                    self.localModels.getAllModels()
                                    self.showLoader = false
//                                }
                            }
                        }
                    }else{
                        self.showLoader = false
                    }
                }
            })
            .onChange(of: networkConnection.isConnected, perform: { isConnected in
                if isConnected{
                    if vm.categories.isEmpty{
                        self.vm.loadCategories { val in
                            self.vm.fetchProducts {
                                self.localModels.getProducts(filters: nil) {
                                    self.localModels.getAllModels()
                                    self.showLoader = false
                                }
                            }
                        }
                    }else{
                        self.showLoader = false
                    }
                }
            })
        .onChange(of: vm.showLoader) { newValue in
            self.showLoader = newValue
        }
    }
}
