//
//  AuthRootVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.02.2022.
//

import SwiftUI
import Alamofire
import Amplitude
import SwiftyJSON

class AuthRootVM: ObservableObject {
    
    enum PasswordError: CaseIterable {
        case charactersCount
        case oneUppercaseLetter
        case oneDigit
        case oneLowercaseLetter
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Published var email: String = ""{
        didSet{
            if currentPage == .registration{
                emailTFState = email.isEmailValid ? .success : .def
            }
            
            validateLoginPageButton()
        }
    }
    @Published var emailTFState: TextFieldState = .def
   
    @Published var password: String = ""{
        didSet{
           validateLoginPageButton()
        }
    }
    
    
    @Published var passwordTFState: TextFieldState = .def
    
    @Published var nextButtonIsDisabled = true
    @Published var nextButtonState: ButtonState = .def
    
    @Published var showOnboarding = true
    
    @Published var showServerError = false
    @Published var authServerError: ServerError?{
        didSet{
            if !email.isEmpty && !password.isEmpty{
                if let _ = authServerError {
                    passwordTFState = .error
                    emailTFState = .error
                }else{
                    passwordTFState = .def
                    emailTFState = .def
                }
            }
        }
    }
    @Published var errors: [PasswordError] = [.charactersCount, .oneUppercaseLetter, .oneDigit, .oneLowercaseLetter]
    
    
    @Published var currentPage: AuthViewPages = .registration{
        didSet{
            self.errors = []
            self.authServerError = nil
            self.password = ""
        }
    }
    
    @Published var isResetPasswordSheetShow = false
    @Published var showRegisterSteps: Bool = false
    @Published var isUserAuthenticated: Bool = false
    
    
    init() {
        showOnboarding = UserDefaultsService().get(fromKey: .showOnboarding) as? Bool ?? true
    }
    
    
    func validateLoginPageButton(){
        if currentPage == .login && password.count > 0 && email.count > 0{
            nextButtonIsDisabled = false
        }else{
            nextButtonIsDisabled = true
        }
    }
    
    func validatePassword(_ password: String) {
        var errors = [PasswordError]()
        
        switch password {
            case "": errors = [.charactersCount, .oneUppercaseLetter, .oneDigit, .oneLowercaseLetter]
            case let password where password.range(of: PasswordError.oneLowercaseLetter.pattern, options: .regularExpression) == nil:
                errors.append(.oneLowercaseLetter)
                fallthrough
            case let password where password.range(of: PasswordError.oneDigit.pattern, options: .regularExpression) == nil:
                errors.append(.oneDigit)
                fallthrough
            case let password where password.range(of: PasswordError.oneUppercaseLetter.pattern, options: .regularExpression) == nil:
                errors.append(.oneUppercaseLetter)
                fallthrough
                
            default:
                if password.trimmingCharacters(in: .whitespaces
                ).count < 8 {
                    errors.append(.charactersCount)
                }
        }
        self.errors = errors
       
        
        if errors.isEmpty && !email.isEmpty && currentPage == .registration{
            nextButtonIsDisabled = false
        }else{
            nextButtonIsDisabled = true
        }
    }
    
    func userRegister(completionHandler: @escaping () -> Void) {
        let params = ["email" : email,
                      "password" : password]
        
        API.shared.request(rout: .userRegister, method: .post, parameters: params, encoding: JSONEncoding.default) { result in
            switch result {
            case .success(_):
                self.nextButtonState = .success
                self.showServerError = false
                if UserDefaults.standard.bool(forKey: "EnableTracking"){
                    Amplitude.instance().logEvent("email_pass_success")
                }
                completionHandler()
            case .failure(let error):
                if UserDefaults.standard.bool(forKey: "EnableTracking"){
                    Amplitude.instance().logEvent("email_pass_fail", withEventProperties: ["error_type" : error.message])
                }
                self.showServerError = true
                self.nextButtonState = .def
                self.authServerError = ServerError(statusCode: error.statusCode, message: error.message)
                Logger.log(message: error.message, event: .error)
                
            }
        }
    }
    
    func userLogin(needToFillData: @escaping (Bool) -> Void){
        let params = ["email" : email,
                      "password" : password]
        API.shared.request(rout: .userLogin, method: .post, parameters: params , encoding: JSONEncoding.default) { result in
            switch result{
            case let .success(json):
                
                let userData = UserLoginDataModel(json: json)
                
                UserDefaultsService().set(value: userData.accessToken, forKey: .accessToken)
                KeychainService.updatePassword(userData.accessToken, serviceKey: .accessToken)
                
                self.appDelegate.saveTokenFCM()
                self.appDelegate.updatePushNotificationState(true)
                Amplitude.instance().logEvent("login_success")
                print("PHOOONE \(userData.phone)")
                //neet to fill data
                if let phone = userData.phone, !phone.isEmpty{
                    needToFillData(false)
                    print("PHOOONE NEED TO FIL = false")
                }else{
                    needToFillData(true)
                    print("PHOOONE NEED TO FIL = true")
                }
            case let .failure(error):
                print("errorerrror \(error)")
                if UserDefaults.standard.bool(forKey: "EnableTracking"){
                    Amplitude.instance().logEvent("login_fail", withEventProperties: ["error_type" : error.message])
                }
                Logger.log(message: error.message, event: .error)
                self.showServerError = true
                self.nextButtonState = .def
                self.authServerError = ServerError(statusCode: error.statusCode, message: error.message)
            }
        }
    }
    
    
    /// Register user button action
    func userRegisterOld(completionHandler: @escaping () -> Void) {
        UserRepository().userRegister(email: self.email, password: self.password) { result in
            switch result {
            case .success(_):
                self.nextButtonState = .success
                self.showServerError = false
                if UserDefaults.standard.bool(forKey: "EnableTracking"){
                Amplitude.instance().logEvent("email_pass_success")
                }
                completionHandler()
            case .failure(let errorAPI):
                if UserDefaults.standard.bool(forKey: "EnableTracking"){
                Amplitude.instance().logEvent("email_pass_fail", withEventProperties: ["error_type" : errorAPI.localizedDescription])
                }
                self.showServerError = true
                self.nextButtonState = .def
                self.authServerError = errorAPI
                Logger.log(message: errorAPI.localizedDescription, event: .error)
                
            }
        }
    }



    /// Login user button action
    func userLoginOLD(asNewUser: Bool = false, isNewUserLogined: @escaping (Bool) -> Void) {
        if email.isEmailValid {
                LoginRepository()
                    .login(email: self.email, password: self.password) { result in
                        switch result {
                            case .success(let loginData):
                            print("loginData: \(loginData)")
                                DispatchQueue.main.async {
                                    if loginData.phone != nil {
                                        UserDefaultsService().set(value: loginData.phone!, forKey: .phone)
                                    }
                                    
                                    UserDefaultsService().set(value: loginData.id, forKey: .user)
                                   
                                    

                                    let granded = UserDefaultsService().get(fromKey: .fcmGranted) as? Bool
                                 
                                    self.appDelegate.saveTokenFCM()
                                    
                                    /// API `User Enable/Disable Remote Push Notifications`
                                    self.appDelegate.updatePushNotificationState(true)
                                    

                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) {
                                        self.nextButtonState = .success
                                        
                                        Amplitude.instance().logEvent("login_success")
                                        
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) {
                                            if asNewUser{
                                                isNewUserLogined(true)
                                            }else{
                                                isNewUserLogined(false)  
                                            }
                                        }
                                        UserDefaultsService().set(value: true, forKey: .userVerified)
                                    }
                                }
                                
                            case .failure(let errorAPI):
                            if UserDefaults.standard.bool(forKey: "EnableTracking"){
                            Amplitude.instance().logEvent("login_fail", withEventProperties: ["error_type" : errorAPI.localizedDescription])
                            }
                                Logger.log(message: errorAPI.localizedDescription, event: .error)
                                DispatchQueue.main.async {
                                    self.authServerError = errorAPI //errorAPI
                                  UserDefaultsService().set(value: false, forKey: .userVerified)
                                    self.nextButtonState = .def
                                }
                        }
                    }
            
        } else {
            self.nextButtonState = .def
            self.authServerError = ServerError.init(statusCode: 3, message: "Given email or password was invalid.")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) {
                self.showServerError = true
                self.nextButtonState = .def
            }
        }
    }
    
    var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }
}



extension AuthRootVM.PasswordError {
    var errorMessage: String {
        switch self {
            case .charactersCount: return "Eight characters"
            case .oneDigit: return "One digit"
            case .oneLowercaseLetter: return "One lowercase letter"
            case .oneUppercaseLetter: return "One uppercase letter"
        }
    }
    
    var pattern: String {
        switch self {
            case .oneUppercaseLetter: return #"(?=.*[A-Z])"#
            case .oneDigit: return #"(?=.*\d)"#
            case .oneLowercaseLetter: return #"(?=.*[a-z])"#
            case .charactersCount: return #"(?=.{8,})"#
        }
    }
}



struct UserLoginDataModel {
    var id: Int
    var email: String
    var role: String
    var state: String
    var phone: String?
    var accessToken: String
    
    init(json: JSON){
        self.id = json["id"].intValue
        self.email = json["email"].stringValue
        self.role = json["role"].stringValue
        self.state = json["state"].stringValue
        self.phone = json["phone"].stringValue
        self.accessToken = json["accessToken"].stringValue
    }
}
