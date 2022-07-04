//
//  HomeView.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 03.08.2021.
//

import SwiftUI
import RealityKit
import SDWebImageSwiftUI
 

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
    
    @State var openProductById: Int = 0
    @State var openByCategoryId: Int = 0
    @State var singleProduct: ProductModel?
    
    @State var disableFilterButton = true
    
    @StateObject var cameraManager = CameraManager()
    
    @StateObject var filtersVM = ARFiltersVM()
    @State var showBG = false
    @State var showCameraSettings = false
    
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
                .customDefaultAlert(title: "Unable to access the Camera",
                                    message: "To use AR, please\nenable camera in Settings.",
                                    isPresented: $showCameraSettings,
                                    firstBtn: Alert.Button.default(Text("Not right now"),
                                                                   action: {
                    showCameraSettings = false
                }), secondBtn: Alert.Button.default(Text("Settings"), action: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                // Finished opening URL
                            })
                        } else {
                            // Fallback on earlier versions
                            UIApplication.shared.openURL(settingsUrl)
                        }
                    }

                }))
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
                    openByCategoryId = 0
                    openProductById = 0
                }
                .onReceive(cameraManager.$permissionGranted, perform: { (granted) in
                    if granted {
                        showBG = false
                    }else{
                        showBG = true
                        showCameraSettings = true
                    }
                })
                .onUIKitAppear {
                    cameraManager.requestPermission()
                    carousel.showDescriptionCard()
                    carousel.openWithDetail = false
                    if openByCategoryId != 0 {
                        ARModelsManager.shared.getProducts(categoryId: openByCategoryId, filters: CatalogFilters()){
                            ARModelsManager.shared.updateModels(){ items in
                                carousel.updateProducts(items: items)
                            }
                        }
                    }
                    
                    if let product = singleProduct{
                        let items = [product.id: (product.modelHighQualityLink, product.animationDuration)]
                        carousel.updateProducts(items: items)
                        carousel.resumeScene()
                        carousel.openWithDetail = true
                        carousel.shouldShowDescriptionCard = true
                    }
                    
//                    if openProductById != 0{
//                        carousel.pauseScene()
//                        ARModelsManager.shared.getProducts(filters: CatalogFilters()){
//                            ARModelsManager.shared.updateModels(){ items in
//                                carousel.updateProducts(items: items)
//                                carousel.manager.setFirstModelId(id: openProductById)
//                            }
//                        }
//                        carousel.resumeScene()
//                        carousel.shouldShowDescriptionCard = true
//                        print("IDDDDDPRODUUCT: \(openProductById)")
//                    }else{
//                        carousel.resumeScene()
//                    }
                    
                     if openProductById == 0 && openByCategoryId == 0{
                        ARModelsManager.shared.getProducts(filters: CatalogFilters()){
                            ARModelsManager.shared.updateModels(){ items in
                                carousel.updateProducts(items: items)
                            }
                        }
                    }
                    
                    statusBarStyle.currentStyle = .darkContent
                    //                tabbarManager.isCurrentOrderViewExtended = false
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
                            
//                            Button {
//                                filtersVM.showFilterView = true
//                            } label: {
//                                Image("navbar-filter")
//                                    .frame(width: 24, height: 24, alignment: .leading)
//                            }
//                            .disabled(disableFilterButton)
//                            .onAppear(){
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//                                    self.disableFilterButton = false
//                                }
//                            }
                        }) // HStack
                        .foregroundColor(.lightOnSurfaceA.opacity(1.0))
                )
                
                if tutorialsIsActive {
                    TutorialsView(isShown: $tutorialsIsActive)
                }
            }// MAIN VSTACK
            
            
            if filtersVM.showFilterView{
                ZStack{
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.fade)
                ARFiltersView(rootVM: filtersVM,
                              carousel: carousel)
                    .transition(.move(edge: .bottom))
                }
            }
            
            
            Color.col_blue_main
                .edgesIgnoringSafeArea(.all)
                .opacity(showBG ? 1 : 0)
            
        } //zstack
        .onChange(of: filtersVM.showFilterView) { newValue in
            if newValue{
                tabbarManager.hide()
            }else{
                tabbarManager.show()
            }
        }
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
                            ProductInfoCapsule(text: "THC: \(product.thc.formattedString(format: .int))%")
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
                        AnalyticsManager.instance.event(key: .add_cart_ar, properties: [.category : product.type.name,
                                                                                        .product_id : product.id,
                                                                                        .product_price : product.price.formattedString(format: .percent)])
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
