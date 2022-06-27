//
//  WeelarApp.swift
//  Weelar
//
//  Created by Bohdan Koshyrets on 8/2/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import UserNotifications
import FirebaseMessaging
import Amplitude
import SwiftyJSON
import AppTrackingTransparency

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    // MARK: - Properties
    private var shouldOpenOrder = false
    
    
    // MARK: - Class functions
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
       
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // FCM
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
              
        // Enable sending automatic session events
        Amplitude.instance().trackingSessionEvents = true
        
        self.requestDataPermission()
        
        // Initialize SDK
        Amplitude.instance().initializeApiKey("fb236e320cc3d63dda12f1d8f09443f1")
        
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        AnalyticsManager.instance.event(key: .app_close)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("REGISTER TOKEN: \(fcmToken)")
        
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("\(#function)")
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Logger.log(message: "userInfo = \(userInfo.description)", event: .severe)
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
    }
    
    
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        
        return false
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo

      // ...

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print full message.
        let json = JSON(userInfo)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let id = json["id"].intValue
            let type = json["type"].intValue

            print("IDORDER: \(id)")
            if id != 0{
                DeepLinks.shared.data = DeeplinkModel(id: id, type: type)
                NotificationCenter.default.post(name: .showDeeplinkOrderTracker, object: nil)
                AnalyticsManager.instance.event(key: .app_start, properties: [.source: "push notification"])
            }
        }

      completionHandler()
    }
    
    // Remote Push Notifications
    func requestAuthorization() {
        
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .sound],
                                  completionHandler: { granted, error in
                guard
                    error == nil
                else {
                    Logger.log(message: error!.localizedDescription, event: .error)
                    return
                }
                Messaging.messaging().isAutoInitEnabled = true
                
                self.saveTokenFCM()
                
                /// API `User Enable/Disable Remote Push Notifications`
                self.updatePushNotificationState(true)
                
            })
        
    }
    
    func requestDataPermission() {
        if #available(iOS 14, *) {
            print("start tracking")
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    switch status {
                    case .authorized:
                        // Tracking authorization dialog was shown
                        // and we are authorized
                        print("Authorized")
                        UserDefaults.standard.set(true, forKey: "EnableTracking")
                    case .denied:
                        // Tracking authorization dialog was
                        // shown and permission is denied
                        print("Denied")
                        UserDefaults.standard.set(false, forKey: "EnableTracking")
                    case .notDetermined:
                        // Tracking authorization dialog has not been shown
                        print("Not Determined")
                        UserDefaults.standard.set(false, forKey: "EnableTracking")
                    case .restricted:
                        print("Restricted")
                    @unknown default:
                        print("Unknown")
                    }
                })
            }
        } else {
            //you got permission to track, iOS 14 is not yet installed
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
      ) {
          NotificationCenter.default.post(name: .showOrderTracker, object: nil)
          
        completionHandler([[.banner, .sound]])
      }

    /// API `User Enable/Disable Remote Push Notifications`
    func updatePushNotificationState(_ isEnable: Bool) {
        UserRepository
            .shared
            .userPushNotificationChange(isEnable) { result in
                switch result {
                case .success(_):
                    Logger.log(message: "FCM token was \(isEnable ? "enabled" : "disabled")", event: .debug)

                case .failure(let error):
                    Logger.log(message: error.localizedDescription, event: .error)
                }
            }
    }
    
     func saveTokenFCM() {
        DispatchQueue.main.async {
            Messaging.messaging().token { token, error in
                guard
                    error == nil
                else {
                    Logger.log(message: error!.localizedDescription, event: .error)
                    return
                }
                
                guard
                    let fcmToken = token
                        
                else {
                    Logger.log(message: "Error fetching FCM registration token", event: .error)
                    return
                }
                
                
                Logger.log(message: "Save FCM Token: \(fcmToken)", event: .severe)
                
                UserRepository
                    .shared
                    .token(fcmToken: fcmToken) { result in }
            }
        }
    }

    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
}

@main
struct WeelarApp: App {
    // MARK: - Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var cartManager = CartManager()
    @StateObject var tabBarManager = TabBarManager()
    @StateObject var coordinatorViewManager = CoordinatorViewManager()
    @StateObject var tabBarViewModel = TabBarViewModel()
    @StateObject var orderTrackerManager = OrderTrackerManager()
    @StateObject var networkConnection = NetworkConnection()
    
    // MARK: - View
    var body: some Scene {
        WindowGroup {
            RootCoordinator()
            
                .onOpenURL { url in
                    print("Received URL: \(url)")
                    Auth.auth().canHandle(url) // <- just for information purposes
                }
                .environmentObject(tabBarViewModel)
                .environmentObject(cartManager)
                .environmentObject(tabBarManager)
                .environmentObject(coordinatorViewManager)
                .environmentObject(orderTrackerManager)
                .environmentObject(networkConnection)
                .environment(\.sizeCategory, .large)
        }
        .onChange(of: scenePhase) { newScenePhase in
             switch newScenePhase {
             case .active:
               print("App is active")
                 if let _  = UserDefaultsService().get(fromKey: .userIsLogged){
                     orderTrackerManager.connect()
                 }
                 print("Order tracker state connect\(orderTrackerManager.isConnected)")
             case .inactive:
               print("App is inactive")
             case .background:
                 print("App is in background")
                 if let _  = UserDefaultsService().get(fromKey: .userIsLogged){
                     orderTrackerManager.disconnect()
                 }
                 print("Order tracker state connect\(orderTrackerManager.isConnected)")
             @unknown default:
               print("Oh - interesting: I received an unexpected new value.")
             }
           }
    }
}

class DeepLinks: ObservableObject {
    static let shared = DeepLinks()
    
    @Published var data: DeeplinkModel = DeeplinkModel(id: 0, type: 0)
    @Published var showDeeplinkView : Bool = false
}

struct DeeplinkModel {
    var id: Int
    var type: Int
}
