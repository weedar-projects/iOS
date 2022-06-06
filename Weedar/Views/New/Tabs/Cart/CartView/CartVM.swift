//
//  CartVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.03.2022.
//

import SwiftUI

class CartVM: ObservableObject {
    @Published var alertClearCartShow = false
    @Published var priceСorresponds = false
    
    @Published var canNext = false
    
    @Published var totalConcentrated: Double = 0.0
    @Published var totalNonConcentrated: Double = 0.0
    
    @Published var minimalSumForOrder: Double = 50
    @Published var showDiscontCodeView = false
    @Published var dailyConcentratedAllowance: Double = 8.0
    @Published var dailyNonConcentratedAllowance: Double = 28.5
    
    @Published var userDiscount = false
    
    func validateToNext(concentrated: Double, nonConcentrated: Double, sum: Double){
        print("concentrated : \(concentrated) | dailyConcentratedAllowance: \(dailyConcentratedAllowance)  \nnonConcentrated: \(nonConcentrated) | dailyNonConcentratedAllowance \(dailyNonConcentratedAllowance) \nsum: \(sum) | \(minimalSumForOrder)")
        
        if concentrated < dailyConcentratedAllowance && nonConcentrated < dailyNonConcentratedAllowance && sum >= minimalSumForOrder{
            canNext = true
        }else{
            canNext = false
        }
    }
    
    func validateSum(sum: Double){
        if sum >= minimalSumForOrder{
            priceСorresponds = true
        }else{
            priceСorresponds = false
        }
    }
}
