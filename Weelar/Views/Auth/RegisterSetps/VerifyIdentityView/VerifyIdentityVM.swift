//
//  VerifyIdentityVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.03.2022.
//

import SwiftUI

class VerifyIdentityVM: ObservableObject {
    
    enum PhotoSelected {
        case id
        case rec
    }
    
    @Published var buttonState: ButtonState = .def
    @Published var buttonIsDisabled = true
    
    @Published var isVerificationImageUploading: Bool = false
    @Published var enableSecondPhoto: Bool = false

    @Published var totalProgress: Float = 0
    
    @Published var selectedPhoto: PhotoSelected = .id
    
    @Published var descriptionText: NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    @Published var idImage: UIImage?
    @Published var idUploadProgress: Float = 0
    @Published var needToLoadIdImage = true
    
    @Published var recommendationImage: UIImage?
    @Published var recommendationUploadProgress: Float = 0
    @Published var needToLoadRecImage = false
    
    
    @Published var isWebViewShow: Bool = false
    @Published var isPrivacyPolicy: Bool = false
    @Published var isPhoneVerified: Bool = false
    @Published var isTermsConditions: Bool = false
    
    @Published var isActionSheetShow: Bool = false
    @Published var isImagePickerShow: Bool = false
    @Published var isImagePicker: Bool = false
    
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Published var stepSuccess = false
    
    @Published var idImageChanged = false
    @Published var recommendationidImageChanged = false
        
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
    
    
    func veryfiIdentity(success: @escaping (Bool) -> Void){
        uploadImages { [weak self] progress in
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
    
    private func uploadImages(progress: @escaping (Float) -> Void, success: @escaping (Bool) -> Void) {
      UserRepository.shared.verifyPassport(passportImage: idImage,
                                           physImage: recommendationImage,
                                           finishRegistration: true,
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
