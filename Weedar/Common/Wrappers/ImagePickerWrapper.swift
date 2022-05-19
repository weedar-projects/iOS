//
//  ImagePickerWrapper.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 22.09.2021.
//

import SwiftUI

struct ImagePickerWrapper: UIViewControllerRepresentable {
    // MARK: - Properties
    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode

    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    
    // MARK: - Custom functions
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerWrapper>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerWrapper>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        // MARK: - Properties
        var parent: ImagePickerWrapper

        
        // MARK: - Initialization
        init(_ parent: ImagePickerWrapper) {
            self.parent = parent
        }

        
        // MARK: - Class functions
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                print("OBOLOG Image \(image.imageOrientation)")
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
