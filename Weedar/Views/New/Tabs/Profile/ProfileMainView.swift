//
//  ProfileMainView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.04.2022.
//

import SwiftUI
import FirebaseMessaging
 

struct ProfileMainView: View {
    
    @StateObject var vm = ProfileMainVM()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var coordinatorManager: CoordinatorViewManager
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var networkConnection: NetworkConnection
    @StateObject var userIdentificationRootVM = UserIdentificationRootVM()
    var body: some View {
        NavigationView{
            ZStack{
                NavigationLink(isActive: $vm.showView) {
                    switch vm.selectedItem {
                    case .orders:
                        MyOrdersListView()
                    case .documents:
                        DocumentCenterView()
                            .navBarSettings("Document center")
                    case .email:
                        ChangeEmailView(){
                            updateDataPhoneEmail()
                        }
                    case .phone:
                        ChangePhoneView(){
                            updateDataPhoneEmail()
                        }
                        .navBarSettings("Change phone \nnumber")
                    case .notification:
                        EmptyView()
                    case .changePassword:
                        ChangePasswordView()
                    case .contact:
                        ContactUsView()
                    case .legal:
                        WebViewWrapper(url: URLs.termsConditions.parameters.url)
                            .padding()
                            .navBarSettings("Terms & Conditions")
                    }
                } label: {
                    EmptyView()
                }
                .isDetailLink(false)
                .onChange(of: networkConnection.isConnected) { newValue in
                    if newValue{
                        vm.showView = false
                    }
                }
                Color.white
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack{
                        ProfileList(selectedItem: $vm.selectedItem, showView: $vm.showView,title: "My info" ,menuItems: $vm.myInfoItems)
                        
                        ProfileList(selectedItem: $vm.selectedItem, showView: $vm.showView,title: "Settings" ,menuItems: $vm.settingsItems)
                        
                        NotificationButtonView()
                        .customDefaultAlert(title: "\"WEEDAR\" Would Like to \nSend You Notifications", message: "Notifications may include alerts,\nsounds and icon badges.These can be configured in Settings", isPresented: $vm.showNotificationAlert, firstBtn: Alert.Button.destructive(Text("Cancel")), secondBtn: Alert.Button.default(Text("Open Settings"), action: {
                            if let appSettings = URL(string: UIApplication.openSettingsURLString),
                               UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        }))
                        
                        ProfileList(selectedItem: $vm.selectedItem, showView: $vm.showView,title: "App" ,menuItems: $vm.appItems)
                        
                        LogOutButton()
                            .padding(.top,24)
                            .customDefaultAlert(title: "Log out",
                                                message: "You will be returned to the login screen.",
                                                isPresented: $vm.showLogOutAlert,
                                                firstBtn: .default(Text("Cancel")),
                                                secondBtn: .destructive(Text("Log out"),
                                                                        action: {
                                self.logout()
                            }))
                        
                        DeleteProfileButtton()
                            .padding(.top,8)
                            .customDefaultAlert(title: "Delete account",
                                                message: "Are you sure you want to delete your account? This action cannot be undone.",
                                                isPresented: $vm.showDeleteAccountAlert,
                                                firstBtn: .default(Text("Cancel")),
                                                secondBtn: .destructive(Text("Delete"),
                                                                        action: {
                                self.deleteProfile {
                                    self.logout()
                                }
                            }))

                        if let info = Bundle.main.infoDictionary, let currentVersion = info["CFBundleShortVersionString"] as? String {
                            Text("v\(currentVersion)")
                                .textSecond()
                                .padding(.top, 14)
                                .padding(.bottom, 35)
                                .padding(.bottom, tabBarManager.showOrderTracker ? 135 : isSmallIPhone() ? 45 : 35)
                        }
                    }
                    
                }
 
                
                if vm.showLoading{
                    Color.black.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    
                    LoadingAnimateView()
                        .offset(y: -getSafeArea().bottom)
                }
            }
            .navBarSettings("Profile", backBtnIsHidden: true)
            .onUIKitAppear {
                tabBarManager.show()
            }
            
        }
        .id(tabBarManager.navigationIds[2])
        .onAppear {
            vm.notificationToggle = UserDefaultsService().isNotificationsEnabled
            updateDataPhoneEmail()
        }
    }
    
    @ViewBuilder
    func LogOutButton() -> some View {
        ZStack{
            HStack{
                Image("Profile-Logout")
                
                Text("Log out")
                    .textCustom(.coreSansC65Bold, 16, Color.col_pink_button)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.col_bg_second
                            .cornerRadius(12))
            .padding(.horizontal)
        }
        .onTapGesture {
            vm.showLogOutAlert.toggle()
        }
        
    }
    
    @ViewBuilder
    func NotificationButtonView() -> some View{
        ZStack{
            RadialGradient(colors: [Color.col_gradient_blue_second,
                                    Color.col_gradient_blue_first],
                           center: .center,
                           startRadius: 0,
                           endRadius: 220)
            .clipShape(CustomCorner(corners: .allCorners, radius: 12))
            .opacity(0.25)
            
            HStack{
                Image("Profile-Notification")
                
                Text("Notification")
                    .textCustom(.coreSansC65Bold, 16, Color.col_black)
                
                Spacer()
                
                CustomToggle(isOn: $vm.notificationToggle){
                    self.checkUserAnswerAPNS(with: vm.notificationToggle)
                }
                .onTapGesture {
                    AnalyticsManager.instance.event(key: .notification_toogle,properties:  [.notifications_allowance : vm.notificationToggle])
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
    }
    
    func DeleteProfileButtton() -> some View {
        HStack{
            Image("trash")
                .colorInvert()
            Text("Delete my account")
                .textCustom(.coreSansC55Medium, 16, Color.col_text_main)
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.col_gray_main, lineWidth: 1)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
        )
        .onTapGesture {
            vm.showDeleteAccountAlert = true
        }
    }
    
   private func deleteProfile(success: @escaping ()->Void){
        API.shared.request(rout: .user, method: .delete) { result in
            switch result{
            case let .success(_):
                success()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func checkUserAnswerAPNS(with isOnValue: Bool) {
        if isOnValue {
            UNUserNotificationCenter
                .current()
                .getNotificationSettings(completionHandler: { (settings) in
                    if settings.authorizationStatus != .authorized {
                        self.vm.showNotificationAlert = true
                        UserDefaultsService().set(value: false, forKey: .fcmGranted)
                    } else {
                        /// API `User Enable/Disable Remote Push Notifications`
                        appDelegate.updatePushNotificationState(true)
                        UserDefaultsService().set(value: true, forKey: .fcmEnabled)
                        UserDefaultsService().set(value: true, forKey: .fcmGranted)
                    }
                })
        } else {
            /// API `User Enable/Disable Remote Push Notifications`
            appDelegate.updatePushNotificationState(false)
            UserDefaultsService().set(value: false, forKey: .fcmEnabled)
        }
    }
    
    private func logout() {
        FirebaseAuthManager
            .shared
            .signOut { result in
                switch result {
               
                case .success:
                    
                    Messaging.messaging().deleteToken { error in
                        if let error = error {
                            print("error to token \(error)")
                        } else {
                            print("debug: token is deleted")
                            print("TOKEN WAS REMOVE")
                            DispatchQueue.main.async {
                                orderTrackerManager.disconnect()
                                AnalyticsManager.instance.event(key: .logout_success)
                                if let _ = UserDefaultsService().get(fromKey: .accessToken){
                                    UserDefaultsService().remove(key: .accessToken)
                                }
                                KeychainService.removePassword(serviceKey: .accessToken)
                                KeychainService.removePassword(serviceKey: .refreshToken)
                                UserDefaultsService().remove(key: .user)
                                sessionManager.userIsLogged = false
                                sessionManager.needToFillUserData = true
                                UserDefaultsService().set(value: false, forKey: .userVerified)
                                UserDefaultsService().set(value: false, forKey: .userIsLogged)
                                UserDefaultsService().set(value: true, forKey: .needToFillUserData)
                                coordinatorManager.currentRootView = .auth
                            }
                        }
                    }
                    
                    
                case .failure(let error):
                    Logger.log(message: error.localizedDescription, event: .error)
                }
            }
    }
    
    private func updateDataPhoneEmail(){
        sessionManager.userData(withUpdate: true){user in
            guard let phone = user.phone else { return }
            vm.setData(email: user.email, phone: phone)
        }
    }
}

struct ProfileMainView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileMainView()
    }
}



struct CustomToggle: View {
    @State var notification = UINotificationFeedbackGenerator()
    @Binding var isOn: Bool
    var actionOnChange: () -> Void
    var body: some View{
        ZStack{
            Capsule()
                .fill(isOn ? Color.col_black : Color.col_toggle_disable)
                .frame(width: 51, height: 31)
            
            Image.bg_gradient_main
                .resizable()
                .frame(width: 27, height: 27)
                .clipShape(Circle())
                .offset(x: isOn ? 10 : -10)
        }
        .onTapGesture {
            if isOn == false{
                notification.notificationOccurred(.success)
            }
            
            withAnimation {
                isOn.toggle()
            }
        }
        .onChange(of: isOn) { newValue in
            actionOnChange()
        }
    }
}
