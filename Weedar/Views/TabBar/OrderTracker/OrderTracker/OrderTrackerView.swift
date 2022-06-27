//
//  OrderTrackerView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.04.2022.
//

import SwiftUI


enum OrderTrackerPosition{
    case notUse
    case hide
    case middle
    case fullscreen
}

struct OrderTrackerView: View{
    @StateObject var vm = OrderTrackerVM()
    @GestureState var gestureOffset: CGFloat = 0
    
    @State var disableScroll  = false
    
    @Binding var detailScrollValue: CGFloat
    
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    @State private var height: CGFloat = 0
    @State private var openOrder = false
    var body: some View{
        // Bottom Sheet....
        
        // For Getting Height For Drag Gesture...
        ZStack{
            GeometryReader{proxy -> AnyView in
                
                let height = proxy.frame(in: .global).height
                
                return AnyView(
                    ZStack{
                        
                        Color.col_black.cornerRadius(radius: 24, corners: [.topLeft, .topRight])
             
                        VStack(spacing: 0){
                            VStack{
                                Image("ordertrackertoparrow")
                                    .resizable()
                                    .frame(width: 20, height: 5)
                                    .rotationEffect(.radians(!openOrder ? .pi * 2 : .pi),
                                                    anchor: .center)
                                    .padding(.top, 12)
                                Spacer()
                            }
                            .frame(height: 26, alignment: .top)
                            
                            // SCrollView Content....
                            OrderTrackerContentView(detailScrollValue: $detailScrollValue, disableScroll: $disableScroll, openOrder: $openOrder)
                                .padding(.bottom)
                                .padding(.bottom,vm.offset == -((height - 100) / 3) ? ((height - 100) / 1.5) : 0)
                            
                        }
                        .padding(.horizontal, 24)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                        .frame(height: getRect().height)
                    //set currnt order 55
                    
                        .offset(y: height - (orderTrackerManager.currentState?.id == 3 ? 55 : 75))
                        .offset(y: -vm.offset > 0 ? -vm.offset <= (height - 100) ? vm.offset : -(height - 100) : 0)
                        .onChange(of: orderTrackerManager.showPosition, perform: { position in
                            print("change")
                            let maxHeight = height - 75
                            
                            switch position {
                            case .hide:
                                withAnimation {
                                    vm.offset = 0
                                }
                                vm.lastOffset = 0
                                orderTrackerManager.showPosition = .notUse
                            case .middle:
                                withAnimation {
                                    vm.offset = -(maxHeight / 3)
                                }
                                vm.lastOffset = vm.offset
                                orderTrackerManager.showPosition = .notUse
                            case .fullscreen:
                                withAnimation {
                                    vm.offset = -maxHeight
                                }
                                vm.lastOffset = vm.offset
                                orderTrackerManager.showPosition = .notUse
                                AnalyticsManager.instance.event(key: .order_trackbar_view,
                                                                properties: [.current_status : orderTrackerManager.currentState?.state.rawValue])
                            case .notUse:
                                break
                            }
                        })
                        .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
                            
                            out = value.translation.height
                            onChange()
                        }).onEnded({ value in
                            
                            let maxHeight = height - 75
                            withAnimation{
                                // Logic COnditions For Moving States...
                                // Up down or mid....
                                if -vm.offset > 100 && -vm.offset < maxHeight / 2{
                                    // Mid....
                                    vm.offset = -(maxHeight / 3)
                                    withAnimation {
                                        disableScroll = true
                                        openOrder = true
                                    }
                                }
                                else if -vm.offset > maxHeight / 2{
                                    vm.offset = -maxHeight
                                    withAnimation {
                                        disableScroll = false
                                        openOrder = true
                                    }
                                    
                                }
                                else{
                                    vm.offset = 0
                                    withAnimation {
                                        disableScroll = false
                                        openOrder = false
                                    }
                                }
                            }
                            
                            // Storing Last Offset..
                            // So that the gesture can contiue from the last position...
                            vm.lastOffset = vm.offset
                            
                        }))
                )
            }
        }
        .onChange(of: getBlurRadius()) { newValue in
            detailScrollValue = newValue
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeOrderTrackerView), perform: { _ in
            withAnimation {
                vm.offset = 0
            }
            vm.lastOffset = 0
            openOrder = false
        })
    }
    
    
    func playAnimation(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.4, blendDuration: 100.0).speed(1.5)) {
                vm.offset = -(getRect().height / 8)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.4, blendDuration: 100.0).speed(1.5)) {
                vm.offset = 0
            }
        }
    }
    
    
    func onChange(){
        DispatchQueue.main.async {
            vm.offset = gestureOffset + vm.lastOffset
        }
    }
    
    // Blur Radius For BG>..
    func getBlurRadius()->CGFloat{
        
        let progress = -vm.offset / (UIScreen.main.bounds.height - 200) / 5
//        print("\(progress * 30 <= 30 ? progress * 30 : 30)")
        return progress * 30 <= 30 ? progress * 30 : 30
    }
}
