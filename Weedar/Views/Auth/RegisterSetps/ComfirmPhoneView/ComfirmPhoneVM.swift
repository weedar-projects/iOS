//
//  ComfirmPhoneVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.03.2022.
//

import SwiftUI
import Alamofire
 
import FirebaseAuth

class ComfirmPhoneVM: ObservableObject {
    
    @Published var otpBorderColor: Color = .clear
    
    var resendCodeQty = 0
    
    @Published var otpField = "" {
        didSet {
            guard
                otpField.count <= 6,
                otpField.last?.isNumber ?? true
            else {
                otpField = oldValue
                
                return
            }
            
            if otpField.count < oldValue.count {
                isErrorShow = false
                errorMessage = ""
            }
            
            print("errormessage: \(errorMessage)")
            print("otp: \(otpField) count: \(otpField.count)")
            print("verify: \(verificationID)")
        }
    }
    
    @Published var stepSuccess = false
    
    var timer = Timer()
    
    @Published var secondsLeft = 60
    
    @Published var userId = 0
    
    @Published var isErrorShow: Bool = false {
        didSet {
            if isErrorShow {
                otpBorderColor = Color.lightSecondaryE.opacity(0.1)
            } else {
                otpBorderColor = Color.lightSecondaryB.opacity(0.4)
            }
        }
    }
    
    @Published var errorMessage: String = ""
    
    @Published var isResendCodeTimerShow: Bool = false
    
    let ud = UserDefaultsService()
    
    var verificationID: String = ""
    
    var phoneNumber: String = ""
    
    var formatPhone: String = ""
    
    func comfirm(){
        self.isErrorShow = false
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID, verificationCode: self.otpField)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let authResult = authResult {
                guard let userPhone = authResult.user.phoneNumber else{
                    return
                }
                self.formatPhone = userPhone
                self.ud.set(value: userPhone, forKey: .phone)
                self.verifyPhoneNumber()
                AnalyticsManager.instance.event(key: .number_confirm_success)
            } else {
                guard let error = error else { return }
                AnalyticsManager.instance.event(key: .number_confirm_fail)
                Logger.log(message: error.localizedDescription, event: .error)
                self.errorMessage = error.localizedDescription
                self.isErrorShow = true
            }
        }
    }
    
    private func verifyPhoneNumber() {
        let endpoint = Routs.user.rawValue.appending("/\(userId)/verifyPhone")
        
        let params = [
            "phone" : formatPhone
        ]
        
        API.shared.request(endPoint: endpoint, method: .put, parameters: params, encoding: JSONEncoding.default) { result in
            switch result {
            case .success(_):
                self.ud.set(value: self.phoneNumber, forKey: .phone)
                self.stepSuccess.toggle()
            case let .failure(error):
                self.errorMessage = error.message
                self.isErrorShow = true
                Logger.log(message: error.message, event: .error)
            }
        }
    }
}



//MARK: OTP Field
extension ComfirmPhoneVM{
    var otp1: String {
        guard
            otpField.count >= 1
        else {
            return ""
        }
        
        return String(Array(otpField)[0])
    }
    
    var otp2: String {
        guard
            otpField.count >= 2
        else {
            return ""
        }
        
        return String(Array(otpField)[1])
    }
    
    var otp3: String {
        guard
            otpField.count >= 3
        else {
            return ""
        }
        
        return String(Array(otpField)[2])
    }
    
    var otp4: String {
        guard
            otpField.count >= 4
        else {
            return ""
        }
        
        return String(Array(otpField)[3])
    }
    
    var otp5: String {
        guard
            otpField.count >= 5
        else {
            return ""
        }
        return String(Array(otpField)[4])
    }
    
    var otp6: String {
        guard
            otpField.count >= 6
        else {
            return ""
        }
        
        return String(Array(otpField)[5])
    }
}

//MARK: Timer
extension ComfirmPhoneVM{
    
    func timerStart() {
      isResendCodeTimerShow = true
        sendPhoneAuthentication()
        resendCodeQty += 1
        AnalyticsManager.instance.event(key: .resend_code, properties: [.resend_code_qty : resendCodeQty])
      timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        self.secondsLeft -= 1
        
        if self.secondsLeft <= 0 {
          self.timer.invalidate()
          self.secondsLeft = 60
          self.isResendCodeTimerShow = false
        }
      }
    }
    
    func sendPhoneAuthentication() {
        FirebaseAuthManager
            .shared
            .getConfirmationCode(phoneNumber) { result in
                switch result {
                case let .success(verificationID):
                   
                    //verificationID - code for activate number
                    self.verificationID = verificationID
                   
                case let .failure(error):
                    
                    //log
                    Logger.log(message: error.localizedDescription, event: .error)
                    
                    //error found
                    self.isErrorShow = true
                    self.errorMessage = "phonenumberview.phone_number_provide_phone_error".localized
                    
                    break
                }
            }
    }
}
