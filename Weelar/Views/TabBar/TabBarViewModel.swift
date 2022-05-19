//
//  TabBarViewModel.swift
//  Weelar
//

import Combine
import Foundation
import SwiftUI

class TabBarViewModel: ObservableObject {
    @Published var selectedTab: SelectedTab = .catalog
    @Published var offset = CGSize.zero

    @Published var cartNumberLabelWidth = CGFloat.zero
    @Published var tabBarHeight = CGFloat.zero
    @Published var isCurrentOrderViewExtended = false
    @Published var hidden: Bool = true
    
    @Published var orderPickerOpen = false
    @Published var arrowIsMoving = false
    
    @Published var showARView = false
    

    //aviable orders for order tracker
    @Published var availableOrders: [OrderModel] = []
    
    //Order tracker
    @Published var showOrderTracker = false
    @Published var showOrderDetailView = false
    @Published var detailScrollValue: CGFloat = 0
    
    private var cancelables = [AnyCancellable]()
    
    // MARK: - Initialization
    
    func onAppear() {
        hidden = false
        
        UserDefaults.standard.publisher(.tabBarShow)
            .receive(on: RunLoop.main)
            .sink { [weak self] tabBarShow in
                if !tabBarShow {
                    UserDefaults.standard[.tabBarShow] = true
                    self?.arrowIsMoving = true
                    let secondsToDelay = 1.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
                        self?.arrowIsMoving = false
                        self?.isCurrentOrderViewExtended = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay * 2) {
                            self?.isCurrentOrderViewExtended = false
                        }
                    }
                }
            }
            .store(in: &cancelables)
        
        Publishers.CombineLatest($hidden, $tabBarHeight)
            .map { tabBarIsHidden, height in
                tabBarIsHidden ? self.tabBarHeight : .zero
            }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] offset in
                self?.offset.height = offset
            })
            .store(in: &cancelables)
    }
    
    func hide(){
        withAnimation(.linear.speed(2)) {
            hidden = false
        }
    }
    
    func show(){
        withAnimation(.linear.speed(3)) {
            hidden = false
        }
    }
    
    func onDisappear() {
        cancelables = []
    }
}

