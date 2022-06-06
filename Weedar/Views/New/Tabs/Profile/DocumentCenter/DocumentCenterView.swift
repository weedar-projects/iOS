//
//  DocumentCenterView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.04.2022.
//

import SwiftUI
import Amplitude

struct DocumentCenterView: MainLoadViewProtocol {
    
    @StateObject var vm = DocumentCenterVM()
    @EnvironmentObject var orderNavigationManager: OrderNavigationManager
    @State var showLoader = true
    var documenLoaded: (Bool) -> Void = { _ in }
    
    var content: some View {
        VStack{
            ScrollView(.vertical, showsIndicators: false) {
                //description
            Text("phonenumberview.phone_number_verify_identity_note".localized)
                .textSecond()
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .hLeading()
                
                Text("Our courier will ask you to show your ID \nto verify your identity and age.")
                    .textDefault()
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    .hLeading()
            
                PassportView()
  
                RecomendationView()
                
                Text("[Terms & Conditions](https://api.weedar.tech/termsAndConditions) and [Privacy Policy](https://api.weedar.tech/privacyPolicy) of the Service")
                    .textSecond()
                    .padding(.horizontal)
                    .padding(.top,24)
                    .multilineTextAlignment(.center)
                    
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled,showIcon: false ,title: "Save") {
                    print("LOADING IMAGE")
                    vm.updateImages {
                        self.showLoader = true
                        print("LOADED IMAGE")
                        vm.updateScreen()
                        if orderNavigationManager.needToShowDocumentCenter{
                            orderNavigationManager.needToShowDocumentCenter = false
                            documenLoaded(true)
                        }
                        
                    }
                }
                .padding(.top)
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
                
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if orderNavigationManager.needToShowDocumentCenter{
                    Button {
                        withAnimation {
                            orderNavigationManager.needToShowDocumentCenter = false
                        }
                    } label: {
                        Image("xmark")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(.trailing, 10)
                    }
                }
            }
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
                        vm.idImage = image
                        if UserDefaults.standard.bool(forKey: "EnableTracking"){
                        Amplitude.instance().logEvent("id_upload", withEventProperties: ["method_id" :"choose_an_image"])
                        }
                    case .rec:
                        vm.recommendationImage = image
                        if UserDefaults.standard.bool(forKey: "EnableTracking"){
                        Amplitude.instance().logEvent("recommend_id", withEventProperties: ["method_id" :"choose_an_image"])
                        }
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
                ImagePicker(sourceType: vm.sourceType) { image in
                    switch vm.selectedPhoto {
                    case .id:
                        vm.idImage = image
                        if UserDefaults.standard.bool(forKey: "EnableTracking"){
                        Amplitude.instance().logEvent("id_upload", withEventProperties: ["method_id" :"take_a_photo"])
                        }
                    case .rec:
                        vm.recommendationImage = image
                        if UserDefaults.standard.bool(forKey: "EnableTracking"){
                        Amplitude.instance().logEvent("recommend_id", withEventProperties: ["method_id" :"take_a_photo"])
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
        
        LoadPhotoView(value: $vm.idUploadProgress, selectedImage: $vm.idImage, showLoader: $vm.idImageChanged) {
            vm.selectedPhoto = .id
            vm.isActionSheetShow.toggle()
        } trashAction: {
            vm.idImage = nil
            if UserDefaults.standard.bool(forKey: "EnableTracking"){
            Amplitude.instance().logEvent("remove_id")
            }
        }
        .padding(.horizontal, 24)
        .onChange(of: vm.idImage) { newValue in
            vm.idImageChanged = true
            vm.buttonIsDisabled = false
//            if newValue != nil{
//                vm.buttonIsDisabled = false
//            }else{
//                vm.buttonIsDisabled = true
//            }
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
            Amplitude.instance().logEvent("remove_recommend")
            }
        }
        .padding(.horizontal, 24)
        .onChange(of: vm.recommendationImage) { newValue in
            vm.recommendationidImageChanged = true
            vm.buttonIsDisabled = false
//            if vm.idImage != nil{
//                vm.buttonIsDisabled = false
//            }else{
//                vm.buttonIsDisabled = true
//            }
        }
    }
    
    var loader: some View{
        LoadingDocumentCenterView()
            .onAppear{
                vm.prepareDescriptionText()
                vm.getUserInfo {
                    self.showLoader = false
                }
            }
    }
}
