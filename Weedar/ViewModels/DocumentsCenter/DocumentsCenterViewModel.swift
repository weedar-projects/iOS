//
//  DocumentsCenterViewModel.swift
//  Weelar
//
//  Created by vtsyomenko on 27.09.2021.
//

import Combine
import Foundation
import SwiftUI
import Amplitude

final class DocumentsCenterViewModel: ObservableObject {
  enum ImageType: Identifiable {
    var id: Self { self }
    
    case photoId
    case physician
  }
  
    @Published var userInfo: UserResponse?
    @Published var physicianRecImage: UIImage?
    @Published var idImage: UIImage?
    @Published var withPrescription: Bool = true
    //
    //    @Published var showIdImagePicker: Bool = false
    //    @Published var showPhysImagePicker: Bool = false
    //
    @Published var loadingIndicatorShow: Bool = false // almost unused?
    @Published var isUploadingId: Bool = false
    @Published var isUploadingPhysicianRec: Bool = false
    @Published var width: CGFloat = 0
    @Published var height: CGFloat = 0
    
    @Published var imageSeclected = false
    @Published var offsetID = CGSize.zero
    @Published var offsetPhys = CGSize.zero
    @Published var showIDDelete = false
    @Published var showPhysDelete = false
    @Published var showImagePicker: ImageType?
    @Published var idUploadProgress: Float = 0
    @Published var physRecUploadProgress: Float = 0
    @Published var totalProgress: Float = 0
    @Published var isLoadingId: Bool = true
    @Published var isLoadingPhysicianRec: Bool = true

    private var cancelables = [AnyCancellable]()
    var isImageUploaded: Bool = false

    func onAppear() {
    getUserInfo { [weak self] userInfo in
      self?.userInfo = userInfo
    }
    //PrivateRepository.shared.imagePublisher(physicianRecPhotoLink)
    
    $userInfo
      .compactMap {$0}
      .receive(on: RunLoop.main)
      .sink { [weak self] info in
       
          if let passId = self?.userInfo?.passportPhotoLink {
          //self?.isLoadingId = true
          self?.getImage(passId) { [weak self] image in
            self?.idImage = image
            self?.isLoadingId = false
          }
        } else {
            self?.isLoadingId = false
        }
        
        if let physLink = self?.userInfo?.physicianRecPhotoLink {
         // self?.isLoadingPhysicianRec = true
          self?.getImage(physLink) { [weak self] image in
            self?.physicianRecImage = image
            self?.isLoadingPhysicianRec = false
          }
        } else {
            self?.isLoadingPhysicianRec = false
        }
      }
      .store(in: &cancelables)
    
    Publishers
      .CombineLatest($isLoadingId, $isLoadingPhysicianRec)
      .map { $0 || $1 }
      .removeDuplicates()
      .receive(on: RunLoop.main)
      .sink { [weak self] isLoading in
                        self?.loadingIndicatorShow = isLoading
//                      self.isLoading = isLoading
      }
      .store(in: &cancelables)
  }
  
  func onDisappear() {
    cancelables = []
  }
  
  func removeImage(imageType: ImageType) {
    switch imageType {
      case .photoId:
        deletePhoto(physRec: false) { result in
          print("IDPhoto delete result: \(result)")
        }
        idImage = nil
        showIDDelete = false
        offsetID = .zero
      case .physician:
        deletePhoto(physRec: true) { result in
          print("RecPhoto delete result: \(result)")
        }
        physicianRecImage = nil
        UserDefaults.standard[.userHasRecPhoto] = false
        offsetPhys = .zero
    }
  }
  
  func getImage(_ photoLink: String, _ finished: @escaping (UIImage?) -> Void) {
    PrivateRepository.shared.getPrivateImage(photoLink) { result in
      switch result {
        case .success(let image):
          finished(image)
        case .failure(_):
          print("Error: failed to get \(photoLink) image")
          print(result)
          finished(nil)
      }
    }
  }
  
  func deletePhoto(physRec: Bool, finished: @escaping (Bool) -> Void) {
    guard let id = UserDefaultsService().get(fromKey: .user) as? Int else {
      print("Can'r get ID from Defaults")
      return
    }
    
    UserRepository.shared.deletePassportPhoto(physRec: physRec, id: id) { result in
      switch result {
        case .success(_):
          print("Photo delete Success")
          finished(true)
        case .failure(_):
          print("Photo delete Failure")
          finished(false)
      }
    }
  }
  
    func uploadTapped() {
        uploadImages(progress: { [weak self] progress in
            DispatchQueue.main.async {
                if progress < 0.5 {
                    self?.idUploadProgress = progress/0.5
                    self?.physRecUploadProgress = 0
                } else {
                    self?.idUploadProgress = 1
                    self?.physRecUploadProgress = (progress - 0.5)/0.5
                }
                self?.totalProgress = progress
            }
        })
    }
    
  // MARK: - Custom functions
    func uploadImages(progress: @escaping (Float) -> Void) {
    // check if at least 1 image uploaded
    loadingIndicatorShow = true
    
    UserRepository
      .shared
      .verifyPassport(passportImage: idImage, physImage: physicianRecImage, progress: progress, completion: { [weak self] result in
        DispatchQueue.main.async {
          self?.loadingIndicatorShow = false
          self?.imageSeclected = false
        }
        switch result {
          case .success(_):
            guard let self = self else { break }
            UserDefaults.standard[.userHasRecPhoto] = self.physicianRecImage != nil
            Amplitude.setAmpUserProperty(key: "recommendation_provided", value: UserDefaults.standard[.userHasRecPhoto] as NSObject)
            DispatchQueue.main.async {
              self.idUploadProgress = 0
              self.physRecUploadProgress = 0
              self.isImageUploaded = true
            }
            break
          case .failure(let error):
            guard let self = self else { break }
            Logger.log(message: error.localizedDescription, event: .error)
            self.isImageUploaded = false
            break
        }
      })
  }
  
  func getUserInfo(finished: @escaping (UserResponse)-> Void) {
    let userId = UserDefaultsService().get(fromKey: .user) as! Int
    
    UserRepository
      .shared
      .getUserInfo(userId: userId) { result in
        switch result {
          case .success(let userInfo):
            finished(userInfo)
            
          case .failure(let error):
            Logger.log(message: error.localizedDescription, event: .error)
        }
      }
  }
  
}
