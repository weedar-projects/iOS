//
//  UserIdentificationRootVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 01.03.2022.
//

import SwiftUI

class UserIdentificationRootVM: ObservableObject {
    
    @Published var providePhoneVM = ProvidePhoneVM()
    @Published var comfirmPhoneVM = ComfirmPhoneVM()
    @Published var deliveryDetailsVM = DeliveryDetailsVM()
    @Published var verifyIdentityVM = VerifyIdentityVM()
    
  
    @Published var currentPage: Int = 0
    @Published var indicatorValue: CGFloat = 2
    
    @Published var needToIdentify = true
    
    
    //update view when steps change
    func updateIndicatorValue(){
        
        withAnimation {
            switch currentPage{
            case 0:
                indicatorValue = 2
            case 1:
                indicatorValue = 1
//            case 2:
//                indicatorValue = 1.5
//            case 3:
//                indicatorValue = 1
            default:
                indicatorValue = 4
            }
        }
    }
    
    //next step page
    func nextPage(){
        if currentPage < 2{
            currentPage += 1
            updateIndicatorValue()
        }
    }
    
    //preview step page
    func backPage(logout: @escaping () -> Void = {}){
        if currentPage > 0{
            if currentPage == 2{
                currentPage = 0
                updateIndicatorValue()
            }else{
                currentPage -= 1
                updateIndicatorValue()
            }
        }else{
            logout()
        }
    }
}

