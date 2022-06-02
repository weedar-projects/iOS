//
//  VerifyIdentityView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 01.03.2022.
//

import SwiftUI
import Amplitude

struct VerifyIdentityView: View {
    
    @StateObject var vm: VerifyIdentityVM
    
    @StateObject var rootVM: UserIdentificationRootVM
    
    @EnvironmentObject var coordinatorViewManager: CoordinatorViewManager
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    
    var body: some View {
        VStack{
            //title
            Text("phonenumberview.phone_number_verify_identity_title".localized)
                .textTitle()
                .padding([.top, .leading], 24)
                .hLeading()
            
            ScrollView(.vertical, showsIndicators: false) {
            
                //description
            Text("phonenumberview.phone_number_verify_identity_note".localized)
                .textSecond()
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .hLeading()
            
                //title id verification
                 
                
                PassportView()
                
                // Physicians toggle
                
                RecomendationView()
                
                Spacer()
                
                Text("By clicking the button I accept [Terms & Conditions](https://api.weedar.tech/termsAndConditions) \nand [Privacy Policy](https://api.weedar.tech/privacyPolicy) of the Service")
                    .textSecond()
                    .padding(.horizontal)
                    .padding(.top,24)
                
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled, title: "welcomeview.welcome_content_next".localized) {
                    vm.veryfiIdentity { success in
                        if success {
                            orderTrackerManager.connect()
                            UserDefaultsService().set(value: false, forKey: .needToFillUserData)
                            sessionManager.needToFillUserData = false
                            coordinatorViewManager.currentRootView = .main
                        }
                    }
                }
                .padding(.top)
                .padding(.horizontal, 24)
                .padding(.bottom)
            }
        }
        .onAppear{
            vm.prepareDescriptionText()
        }
        .actionSheet(isPresented: $vm.isActionSheetShow) {
            ActionSheet(title: Text("Upload Image"),
                        buttons: [
                            .default(
                                Text("phonenumberview.phone_number_verify_identity_album".localized)
                                    .foregroundColor(Color.lightSecondaryE.opacity(1.0))
                                    .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 16))
                            ) {
                                vm.sourceType = .photoLibrary
                                vm.isImagePickerShow.toggle()
                            },
                            .default(
                                Text("phonenumberview.phone_number_verify_identity_camera".localized)
                                    .foregroundColor(Color.lightSecondaryE.opacity(1.0))
                                    .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 16))
                            ) {
                                vm.sourceType = .camera
                                vm.isImagePicker.toggle()
                            },
                            .cancel()
                        ])
        }
        
        //Library view
        .fullScreenCover(isPresented: $vm.isImagePickerShow, content: {
          NavigationView {
              ImagePickerView(sourceType: vm.sourceType) { image in
                  switch vm.selectedPhoto {
                  case .id:
                      if UserDefaults.standard.bool(forKey: "EnableTracking"){
                      Amplitude.instance().logEvent("id_upload", withEventProperties: ["method_id" :"choose an image"])
                      }
                      vm.idImage = image
                  case .rec:
                      if UserDefaults.standard.bool(forKey: "EnableTracking"){
                      Amplitude.instance().logEvent("recommend_upload", withEventProperties: ["method_id" : "choose an image"])
                      }
                      vm.recommendationImage = image
                  }
              }
            .navigationTitle("Choose an image")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                  Button(
                                    action: { vm.isImagePickerShow = false },
                                    label: { Label("Back", systemImage: "chevron.left").foregroundColor(Color.lightOnSurfaceB) }
                                  )
            )
          }
          .edgesIgnoringSafeArea(.all)
        })
        
        //Camera view
        .fullScreenCover(isPresented: $vm.isImagePicker, content: {
          NavigationView {
              ImagePickerView(sourceType: vm.sourceType) { image in
                  switch vm.selectedPhoto {
                  case .id:
                      vm.idImage = image
                      if UserDefaults.standard.bool(forKey: "EnableTracking"){
                      Amplitude.instance().logEvent("id_upload", withEventProperties: ["method_id" : "take a photo"])
                      }
                  case .rec:
                      vm.recommendationImage = image
                      if UserDefaults.standard.bool(forKey: "EnableTracking"){
                      Amplitude.instance().logEvent("recommend_upload", withEventProperties: ["method_id" : "take a photo"])
                      }
                  }
              }
            .navigationTitle("Take a photo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                  Button(
                                    action: { vm.isImagePicker = false },
                                    label: { Label("Back", systemImage: "chevron.left").foregroundColor(Color.lightOnSurfaceB) }
                                  )
            )
          }
          .edgesIgnoringSafeArea(.all)
        })
    }
    
    @ViewBuilder
    func PassportView() -> some View {
        //title id verification
        Text("phonenumberview.phone_number_verify_identity_id_verification".localized)
            .textSecond()
            .hLeading()
            .padding(.leading, 36)
            .padding(.top, 24)
        
        LoadPhotoView(value: $vm.idUploadProgress, selectedImage: $vm.idImage, showLoader: $vm.idImageChanged, needToAnim: true) {
            vm.selectedPhoto = .id
            vm.isActionSheetShow.toggle()
        } trashAction: {
            vm.idImage = nil
            if UserDefaults.standard.bool(forKey: "EnableTracking"){
            Amplitude.instance().logEvent("delete_id_upload")
            }
        }
        .padding(.horizontal, 24)
        .onChange(of: vm.idImage) { newValue in
            vm.idImageChanged = true
            if newValue != nil{
                vm.buttonIsDisabled = false
            }else{
                vm.buttonIsDisabled = true
            }
        }
    }
    
    @ViewBuilder
    func RecomendationView() -> some View {
        Text("Physician's recommendation (optional)")
            .textSecond()
            .hLeading()
            .padding(.leading, 36)
            .padding(.top, 24)
        
        LoadPhotoView(value: $vm.recommendationUploadProgress, selectedImage: $vm.recommendationImage, showLoader: $vm.recommendationidImageChanged) {
            vm.selectedPhoto = .rec
            vm.isActionSheetShow.toggle()
        }trashAction: {
            vm.recommendationImage = nil
            if UserDefaults.standard.bool(forKey: "EnableTracking"){
            Amplitude.instance().logEvent("delete_recommens_upload")
            }
        }
        .padding(.horizontal, 24)
        .onChange(of: vm.recommendationImage) { newValue in
            vm.recommendationidImageChanged = true
            if vm.idImage != nil{
                vm.buttonIsDisabled = false
            }else{
                vm.buttonIsDisabled = true
            }
        }
    }
}


struct LoadPhotoView: View {
    @Binding var value: Float
    @Binding var selectedImage: UIImage?
    @Binding var showLoader: Bool
    
    @State private var minHeight: CGFloat = 106
    @State private var maxHeight: CGFloat = 256
    
    @State var needToAnim = true
    @State var offset: CGFloat = 0
    @State var isSwiped: Bool = false
    
    var action: () -> Void
    var trashAction: () -> Void
    
    var body: some View{
        ZStack{
            //delete button
            ZStack{
                RadialGradient(colors: [Color.col_gradient_pink_second,
                                        Color.col_gradient_pink_first],
                               center: .center,
                               startRadius: 0,
                               endRadius: 150)
                
                Image.icon_trash
                    .colorMultiply(Color.col_pink_button)
            }
            .frame(width: 54, height: selectedImage == nil ? minHeight : maxHeight, alignment: .center)
            .cornerRadius(12)
            .hTrailing()
            .onTapGesture {
                withAnimation(.spring().speed(1.5)) {
                    offset = 0
                }
                    trashAction()
            }

            ZStack{
                Color.col_white
                    .cornerRadius(12)
                
                Color.col_blue_second
                    .cornerRadius(12)
                
                
                if let selectedImage = selectedImage{
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                        .padding(.vertical, 4)
                } else {
                    Text("phonenumberview.phone_number_verify_identity_upload_photo".localized)
                        .textCustom(.coreSansC45Regular, 16, Color.col_black.opacity(0.6))
                }
                VStack{
                    Spacer()
                    if value != 0{
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geometry.size.width , height: geometry.size.height)
                                    .opacity(0)
                                    .foregroundColor(Color.col_white.opacity(0.5))
                                
                                Rectangle()
                                    .fill(Color.col_black)
                                    .cornerRadius(12)
                                    .frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                                    .animation(.linear)
                            }
                        }
                        .frame(height: 6)
                        .padding([.bottom, .horizontal], 2)
                    }
                }
                .opacity(showLoader && selectedImage != nil ? 1 : 0)
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.col_borders, lineWidth: 2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: selectedImage == nil ? minHeight : maxHeight)
            .offset(x: offset)
            .gesture(selectedImage == nil ? nil : DragGesture()
                        .onChanged(onChanged(value:))
                        .onEnded(onEnd(value:)))
            .onTapGesture {
                action()
            }
            
        }
        .onAppear {
            print(UserDefaultsService().get(fromKey: .animDoc) as? Bool ?? true)
            if needToAnim && UserDefaultsService().get(fromKey: .animDoc) as? Bool ?? true{
               DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    animView(start: true)
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        animView(start: false)
                        UserDefaultsService().set(value: false, forKey: .animDoc)
                    }
                }
            }
        }
    }
    
    func animView(start: Bool){
        if start{
            withAnimation(.easeInOut(duration: 0.5)) {
                offset = -80
            }
        }else{
            withAnimation(.easeInOut(duration: 0.5)) {
                offset = 0
            }
        }
    }

    
    //swipe gesture
    func onChanged(value: DragGesture.Value){
        
        if value.translation.width < 0{
            
            if isSwiped{
                offset = value.translation.width - 90
            }
            else{
                offset = value.translation.width
            }
        }
    }
    
    func onEnd(value: DragGesture.Value){
        
        withAnimation(.easeOut){
            
            if value.translation.width < 0{
                //swipe to show button
                if -offset > 50{
                    // updating is Swipng...
                    isSwiped = true
                    offset = -74
                }
                else{
                    isSwiped = false
                    offset = 0
                }
            }
            else{
                isSwiped = false
                offset = 0
            }
        }
    }
}
