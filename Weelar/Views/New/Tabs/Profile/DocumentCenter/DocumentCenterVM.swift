//
//  DocumentCenterVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.04.2022.
//

import SwiftUI
import SwiftyJSON
import Alamofire

class DocumentCenterVM: ObservableObject {
    
    enum PhotoSelected {
        case id
        case rec
    }
    
    @Published var userInfo: UserInfoModel?
    
    @Published var buttonState: ButtonState = .def
    @Published var buttonIsDisabled = true
    
    @Published var isVerificationImageUploading: Bool = false
    
    @Published var totalProgress: Float = 0
    
    @Published var selectedPhoto: PhotoSelected = .id
    
    @Published var descriptionText: NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    @Published var idImage: UIImage?
    @Published var idUploadProgress: Float = 0
    @Published var idImageChanged = false
    
    
    @Published var recommendationImage: UIImage?
    @Published var recommendationUploadProgress: Float = 0
    @Published var recommendationidImageChanged = false
    
    @Published var isWebViewShow: Bool = false
    @Published var isPrivacyPolicy: Bool = false
    @Published var isPhoneVerified: Bool = false
    @Published var isTermsConditions: Bool = false
    
    @Published var isActionSheetShow: Bool = false
    @Published var isImagePickerShow: Bool = false
    @Published var isImagePicker: Bool = false
    
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Published var photoIsLoading = false
        
    func prepareDescriptionText() {
      let fullText = "phonenumberview.phone_number_verify_identity_description".localized
      
      let termsConditionsSubstring = "phonenumberview.phone_number_verify_identity_description_terms".localized
      let privacyPolicySubstring = "phonenumberview.phone_number_verify_identity_description_privacy_policy".localized
      
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = NSTextAlignment.center
      paragraphStyle.lineHeightMultiple = 1.2
      
      let attributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.paragraphStyle : paragraphStyle,
        NSAttributedString.Key.foregroundColor : UIColor(Color.lightOnSurfaceB.opacity(0.4)),
        NSAttributedString.Key.font : UIFont(name: CustomFont.coreSansC45Regular.rawValue, size: 14)!
      ]
      
      let attributedString = NSMutableAttributedString(string: fullText, attributes: attributes)
      attributedString.apply(link: "policy", subString: privacyPolicySubstring)
      attributedString.apply(link: "terms", subString: termsConditionsSubstring)
      
      descriptionText = attributedString
    }
    
    func getUserInfo(_ finished: @escaping () -> Void) {
        guard let id = UserDefaultsService().get(fromKey: .user) as? Int else { return }
        let url = Routs.user.rawValue.appending("/\(id)")
        API.shared.request(endPoint: url) { result in
            switch result{
            case let .success(json):
                self.userInfo = UserInfoModel(json: json)
   
                self.setImages { finish in
                    if finish{
                        finished()
                    }
                }
                
            case .failure(_):
                finished()
                break
            }
        }
    }
    
    private func setImages(_ finish: @escaping (Bool) -> Void){
        
        if let recURL = self.userInfo?.physicianRecPhotoLink{
            self.getImage(recURL) { image in
                guard let img = image else { return  }
                self.recommendationImage = img
                finish(false)
            }
        }
        
        if let idURL = self.userInfo?.passportPhotoLink{
            self.getImage(idURL) { image in
                self.idImage = image
                finish(true)
            }
        }
    }
    
    
    
    func getImage(_ photoLink: String, _ finished: @escaping (UIImage?) -> Void) {
        let url = Routs.getPrivateImg.rawValue.appending("\(photoLink)")
        API.shared.requestData(endPoint: url) { result in
            switch result{
            case let .success(data):
                let image = UIImage(data: data)
                finished(image)
            case .failure(_):
                finished(nil)
                break
            }
        }
    }
    
    func updateScreen(){
        self.totalProgress = 0
        self.idUploadProgress = 0
        self.recommendationUploadProgress = 0
        self.buttonState = .def
        self.idImageChanged = false
        self.recommendationidImageChanged = false
        self.buttonIsDisabled = true
    }
    
    func deleteRecImage(finished: @escaping () -> Void) {
        guard let id = userInfo?.id else {
            return
        }
        
        let url = "/user/\(id)/passportPhoto"
        let params = [
            "passportPhotoLink": false,
            "physicianRecPhotoLink": true
        ]
        
        API.shared.request(endPoint: url,method: .delete ,parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(_):
                print("image was delete")
                finished()
            case .failure(_):
                finished()
                print("image was delete")
                break
            }
        }
    }
    
    
    func updateImages(success: @escaping () -> Void){
        guard let _ = idImage, let _ = recommendationImage else {
            print("guardlet")
            self.deleteRecImage {
                print("deleteRecImage")
                self.veryfiIdentity(updatePhusImage: false) { succses in
                    success()
                }
            }
            return
        }
        print("updateImages")
        veryfiIdentity(updatePhusImage: true) { succses in
            success()
            print("veryfiIdentity")
        }
    }

    
    func veryfiIdentity(updatePhusImage: Bool, success: @escaping (Bool) -> Void){
        uploadImages(updatePhusImage: updatePhusImage) { [weak self] progress in
            DispatchQueue.main.async {
                if progress < 0.5 {
                    self?.idUploadProgress = progress/0.5
                    self?.recommendationUploadProgress = 0
                } else {
                    self?.idUploadProgress = 1
                    self?.recommendationUploadProgress = (progress - 0.5)/0.5
                }
                self?.totalProgress = progress
          }
        } success: { succsess in
            success(succsess)
        }
    }
    
    private func uploadImages(updatePhusImage: Bool,progress: @escaping (Float) -> Void, success: @escaping (Bool) -> Void) {
      UserRepository.shared.verifyPassport(passportImage: idImage,
                                           physImage: updatePhusImage ? recommendationImage : nil,
                                           progress: progress, completion: { result in
          switch result {
            case .success(_):
              DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                self.idUploadProgress = 1
                self.recommendationUploadProgress = 1
                self.totalProgress = 1
                self.buttonState = .success
                success(true)
              }
              UserDefaultsService().set(value: true, forKey: .userVerified)
              
            case .failure(let error):
              success(false)
              Logger.log(message: error.localizedDescription, event: .error)
              self.buttonState = .def
              break
          }
          
        })
    }
}
