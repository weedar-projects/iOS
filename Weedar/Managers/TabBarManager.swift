//
//  TabBarManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 16.03.2022.
//

import SwiftUI


enum TabBarPages {
    case catalog
    case cart
    case profile
    case auth
    case userIdentififcation
}

struct TabBarItem: Identifiable {
    var id = UUID()
    var page: Any
    var icon: String
    var title: String
    var tag: TabBarPages
}

class TabBarManager: ObservableObject {
    
    @Published var currentTab: TabBarPages = .catalog
    
    @Published var tabBarHeight: CGFloat = isSmallDevise ? 66 : 86
    @Published var tabBarBottomPadding: CGFloat = isSmallDevise ? 66 : 50
    
    @Published var showARView = false
    
    @Published var isHidden = false
    
    @Published var orderTrackerHidePage = false
    
    @Published var showDiscountAlert = true
    
    @Published var navigationIds = [UUID().uuidString, UUID().uuidString,UUID().uuidString]
    
    //Order tracker
    @Published var showOrderTracker = false{
        didSet{
            print("ORDER SHOWWWW: \(showOrderTracker)")
        }
    }
    
    @Published var showOrderDetailView = false
    @Published var detailScrollValue: CGFloat = 0
    @Published var avaibleOrdersCount = 0
    
    @Published var tabBarPages = [
        TabBarPageModel(page: CatalogView(localModels: ARModelsManager.shared),
                   icon: "tab-catalog-2d",
                   title: "Catalog",
                   tag: .catalog),
        
        TabBarPageModel(page: CartRootView(),
                   icon: "tab-cart",
                   title: "Cart",
                   tag: .cart),
        
        TabBarPageModel(page: ProfileMainView(),
                   icon: "tab-profile",
                   title: "Profile",
                   tag: .profile)
    ]
    
    
    func hide(){
        DispatchQueue.main.async {
            withAnimation(.linear.speed(2)) {
                self.isHidden = true
            }
        }
    }
    
    func show() {
        DispatchQueue.main.async {
            withAnimation(.linear.speed(3)) {
                self.isHidden = false
            }
        }
    }
    
    func hideTracker(){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            withAnimation(.linear.speed(2)) {
                self.showOrderTracker = false
            }
        }
    }
    
    func showTracker() {
        if avaibleOrdersCount > 0 && !orderTrackerHidePage{
            withAnimation(.linear.speed(1)) {
                showOrderTracker = true
                
            }
        }
    }
    
    func refreshNav(tag: TabBarPages) {
        switch tag {
        case .catalog:
            navigationIds[0] = UUID().uuidString
        case .cart:
            navigationIds[1] = UUID().uuidString
        case .profile:
            navigationIds[2] = UUID().uuidString
        case .auth:
            break
        case .userIdentififcation:
            break
        }
    }
}

