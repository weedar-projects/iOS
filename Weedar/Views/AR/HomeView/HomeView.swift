//
//  HomeView.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 03.08.2021.
//

import SwiftUI
import RealityKit
import SDWebImageSwiftUI
import Amplitude

struct LoadingAnimateView: View {
    @State var animation = true
    var body: some View{
        
        AnimatedImage(name: "loader_gif.gif", isAnimating: $animation)
            .resizable()
            .frame(width: 100, height: 100)
        
    }
}

struct HomeView: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.localStatusBarStyle) var statusBarStyle

    @EnvironmentObject var tabbarManager: TabBarManager    
    
    @State var tutorialsIsActive: Bool = false
    @StateObject var carousel: CarouselARView = ARModelsManager.shared.carusel!
    
    @State private var loadingIndicator = true
    @State private var appear = true
    @State private var opacity = 1.0
    @State private var showDesctiption = true
    
    // MARK: - View
    var body: some View {
        
        ZStack{
            VStack {
                if loadingIndicator {
                    LoadingAnimateView()
                        .padding(.bottom, 20)
                        .padding(.bottom, getSafeArea().top)
                }
            } // VStack
            .zIndex(9)
            //        .onChange(of: startActivity) { _ in
            //            if productsViewModel.isActivityLoadSuccess {
            //                withAnimation(Animation.spring().delay(0.5)) {
            //                    productsViewModel.isActivityLoadShow = false
            //                }
            //            }
            //        }
            
//            Image("arbgcompany")
//                .resizable()
//                .scaledToFit()
//                .frame(width: getRect().width)
//                .vTop()
//                .zIndex(3)
//                .edgesIgnoringSafeArea(.top)
//            
            VStack {
                VStack {
                    ARViewContainer(carousel: carousel, appear: $appear)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(ZStack {
                            if let product = carousel.highlightedProduct  {
                                if carousel.tutorialStage == .hide || carousel.tutorialStage == .show {
                                    ARProductInfo(product: product, opacity: $opacity)
                                        .ignoresSafeArea(edges: .bottom)
                                    //                            .opacity(opacity)
                                }
                            }
                        }) // OVERLAY
                        .overlay(
                            Tutorial(stage: $carousel.tutorialStage)
                                .padding(24)
                                .padding(.bottom, 50)
                        )
                    
                        .zIndex(6)
                } //AR VSTACK
                .statusBar(hidden: true)
                .navigationBarBackButtonHidden(true)
                .onChange(of: carousel.highlightedProduct?.id) { _ in
                    withAnimation(.easeIn(duration: 0.2)) {
                        opacity = 0.2
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeIn(duration: 0.2)) {
                            opacity = 1.0
                        }
                    }
                }
                .onDisappear() {
                    self.appear = false
                    carousel.pauseScene()
                    tabbarManager.showTracker()
                }
                .onUIKitAppear {
                    carousel.showDescriptionCard()
                    statusBarStyle.currentStyle = .darkContent
                    //                tabbarManager.isCurrentOrderViewExtended = false
                    carousel.resumeScene()
                    tabbarManager.hideTracker()
                    self.appear = true
                    withAnimation(Animation.spring().delay(0.5)) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            loadingIndicator = false
                        }
                    }
                }
                .navigationBarItems(
                    leading:
                        Button {
                            carousel.coachingOverlay?.setActive(false, animated: false)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack(alignment: .center, spacing: 12) {
                                Image("arrow-back")
                                    .frame(width: 24, height: 24, alignment: .leading)
                                    .foregroundColor(.lightOnSurfaceA.opacity(1.0))
                                
                                Text("homeview.home_back_button_title".localized)
                                    .lineLimit(1)
                                    .lineSpacing(4.8)
                                    .modifier(TextModifier(font: .coreSansC65Bold, size: 16, foregroundColor: .lightOnSurfaceA, opacity: 1.0))
                            }
                        },
                    trailing:
                        HStack(alignment: .center, spacing: 8, content: {
                            Button {
                                carousel.resetState()
                            } label: {
                                Image("navbar-refresh")
                                    .frame(width: 24, height: 24, alignment: .leading)
                            }
                        }) // HStack
                        .foregroundColor(.lightOnSurfaceA.opacity(1.0))
                )
                
                if tutorialsIsActive {
                    TutorialsView(isShown: $tutorialsIsActive)
                }
            }// MAIN VSTACK
        } //zstack
    }
}



struct ARProductInfo : View {
    var product: CarouselARView.ProductAR
    
    @EnvironmentObject var cartManager: CartManager
    @Binding var opacity: Double
    
    var body: some View {
        BottomSheetView(blur: 4.0, backgroundColor: Color.black.opacity(0.4)) {
            if let product = ProductsViewModel.shared.getProduct(id: product.id) {
                HStack {
                    VStack (alignment: .leading) {
                        Text(product.brand.name ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(ColorManager.Buttons.buttonTextInactiveColor)
                            .padding([.top], 16)
                        Text(product.name)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding([.top], 4)
                        HStack {
                            ProductInfoCapsule(text: "THC: \(product.thc.formattedString(format: .percent))%")
                            ProductInfoCapsule(text: product.strain.name)
                            //                      ProductInfoCapsule(text: "Lab test", labTest: true)
                        }
                        .padding([.top], 4)
                        /*
                         HStack {
                         ForEach(product.effects) { effect in
                         Text("\(effect.emoji()) \(effect.name)")
                         .font(.system(size: 14))
                         .foregroundColor(.white)
                         }
                         */
                        HStack {
                            Text("$\(product.price.formattedString(format: .percent))")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Text("\(product.gramWeight.formattedString(format: .gramm))g / \(product.ounceWeight.formattedString(format: .ounce))oz")
                                .font(.system(size: 12))
                                .foregroundColor(ColorManager.Buttons.buttonTextInactiveColor)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                        }.padding(.top, 8)
                    } // VStack
                    Button(action: {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        cartManager.productQuantityInCart(productId: product.id, quantity: .add)
                        if UserDefaults.standard.bool(forKey: "EnableTracking"){
                        Amplitude.instance().logEvent("add_cart_ar", withEventProperties: ["category" : product.type.name,
                                                                                                "product_id" : product.id,
                                                                                                "product_price" : product.price.formattedString(format: .percent)])
                        }
                    }){
                        ZStack{
                            Image.bg_gradient_main
                                .resizable()
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())
                            
                            Image("Item-Add-Button")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 19, height: 19)
                        }
                    }.padding(.top, 6)
                } // HStack
                .padding(.top, 16)
                .padding(.bottom, getSafeArea().bottom + 75)
                .padding([.trailing, .leading], 24)
                .opacity(opacity)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @StateObject var carousel: CarouselARView
   
    @Binding var appear: Bool
    
    func makeUIView(context: Context) -> some ARView {
        let arView = carousel
//        arView.environment.background =  .color(UIColor(Color.col_blue_dark)) 
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        //        print(appear)
        //        if !appear {
        //            uiView.removeFromSuperview()
        //        }
    }
}

struct ProductInfoCapsule: View {
    var text : String
    var labTest = false
    
    var body: some View {
        HStack{
            if labTest {
                Image("Catalog-LabTest-Icon-White")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 13)
                    .offset(x: 11)
            }
            
            Text(text)
                .font(.system(size: 12))
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 12)
                .padding(.top, 8)
                .padding(.bottom, 6)
        }
        .background(Color.black.cornerRadius(100.0).opacity(0.3))
    }
}
