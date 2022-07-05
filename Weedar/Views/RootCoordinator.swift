//
//  RootCoordinator.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.03.2022.
//

import SwiftUI
import RealityKit
import SwiftyJSON

struct RootCoordinator: View {
    //Tab Bar
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var coordinatorViewManager: CoordinatorViewManager
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    @EnvironmentObject var networkConnection: NetworkConnection
    @EnvironmentObject var cartManager: CartManager
    
    @ObservedObject var registerStepsVM = UserIdentificationRootVM()
    
    @StateObject var sessionManager = SessionManager()
    @StateObject var orderNavigationManager = OrderNavigationManager()
    
    @ObservedObject var deepLinksManager = DeepLinks.shared
    
    
    @State var needToUpdate = false
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: CustomFont.coreSansC65Bold.rawValue, size: 32)!]
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.col_black)
    }
    
    var body: some View {
        ZStack{
            // root screen
            switch coordinatorViewManager.currentRootView {
            case .auth:
                AuthRootView()
                    
            case .registerSetps:
                UserIdentificationRootView(vm: registerStepsVM)
            case .main:
                MainView()
                    .environmentObject(orderTrackerManager)
                    .environmentObject(orderNavigationManager)
                    
            }
            
            if needToUpdate{
                ForceUpdateScreenView()
            }
            
            if !networkConnection.isConnected{
                NoInternetConnectionView()
                    .transition(.fade)
            }
        }
        .environmentObject(sessionManager)
        .onAppear {
            self.checkVersion()
            if sessionManager.userIsLogged && !sessionManager.needToFillUserData{
                coordinatorViewManager.currentRootView = .main
                print("GO TO MAIN: userIsLogged: \(sessionManager.userIsLogged), needToFillUserData: \(sessionManager.needToFillUserData)")
            }else if sessionManager.userIsLogged && sessionManager.needToFillUserData{
                print("GO TO FILL USER DATA: userIsLogged: \(sessionManager.userIsLogged), needToFillUserData: \(sessionManager.needToFillUserData)")
                coordinatorViewManager.currentRootView = .registerSetps
            }else {
                print("GO TO AUTH: userIsLogged: \(sessionManager.userIsLogged), needToFillUserData: \(sessionManager.needToFillUserData)")
                coordinatorViewManager.currentRootView = .auth
            }
            //deeplinks
        }
        .onReceive(NotificationCenter.default.publisher(for: .showDeeplinkOrderTracker), perform: { _ in
            let userIsLogged = UserDefaultsService().get(fromKey: .userIsLogged) as? Bool ?? false
            if userIsLogged{
                getOrderState(id: deepLinksManager.data.id) { openInOrderTracker in
                    if openInOrderTracker && !tabBarManager.isHidden{
                        for order in orderTrackerManager.aviableOrders{
                            if order.id == deepLinksManager.data.id{
                                tabBarManager.showARView = false
                                orderTrackerManager.currentOrder = order
                                orderTrackerManager.showPosition = .fullscreen
                                print("show tracker")
                            }
                        }
                    }else{
                        deepLinksManager.showDeeplinkView.toggle()
                    }
                }
            }
            
        })
        .fullScreenCover(isPresented: $deepLinksManager.showDeeplinkView, onDismiss: {
               }, content: {
                   NavigationView{
                       MyOrderView(id: deepLinksManager.data.id, showDeeplink: true)
                   }
               })
        .onChange(of: orderTrackerManager.avaibleCount) { ordersCount in
            tabBarManager.avaibleOrdersCount = ordersCount
        }
        .onReceive(NotificationCenter.default.publisher(for: .showOrderTracker), perform: { _ in
            tabBarManager.showTracker()
        })
        .onReceive(NotificationCenter.default.publisher(for: .hideOrderTracker), perform: { _ in
            tabBarManager.showOrderDetailView = false
            tabBarManager.hideTracker()
        })
        .onChange(of: networkConnection.isConnected) { connect in
            if connect{
                orderTrackerManager.connect()
                tabBarManager.currentTab = .catalog
                tabBarManager.showARView = false
                tabBarManager.refreshNav(tag: .catalog)
                tabBarManager.refreshNav(tag: .cart)
                tabBarManager.refreshNav(tag: .profile)
                if orderTrackerManager.needToShow{
                    tabBarManager.showOrderTracker = true
                }
            }else{
                orderTrackerManager.disconnect()
            }
        }
    }
    
    func getOrderState(id: Int, openInOrderTracker: @escaping (Bool) -> Void){
        
        let endpoint = Routs.getOrderById.rawValue.appending("/\(id)")
        API.shared.request(endPoint: endpoint) { result in
            switch result{
            case let .success(json):
                let state = json["state"].intValue

                if state == 7 || state == 10{
                    openInOrderTracker(false)
                }else{
                    openInOrderTracker(true)
                }
                
                print("order: \(json)")
            case let .failure(error):
                print("error: \(error)")
                break
            }
        }
        
    }
    
    func checkVersion(){
        guard let info = Bundle.main.infoDictionary, let currentVersion = info["CFBundleShortVersionString"] as? String else { return }
        
        API.shared.request(rout: .getAviableVersions) { result in
            switch result {
            case let .success(json):
                let verisons = json["versions"].arrayValue
                if !verisons.isEmpty{
                    if let _ = verisons.first(where: {$0.stringValue == currentVersion}){
                        
                    }else{
                        self.needToUpdate = true
                    }
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}

extension NSNotification.Name {
    static let showOrderTracker = Notification.Name("ShowOrderTracker")
    static let hideOrderTracker = Notification.Name("HideOrderTracker")
    static let openPushOderTracker = Notification.Name("OpenPushOderTracker")
    static let closeOrderTrackerView = Notification.Name("closeOrderTrackerView")
    static let showDeeplinkOrderTracker = Notification.Name("showDeeplinkOrderTracker")
}

