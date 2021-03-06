//
//  EmailTextFieldWrapper.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 14.10.2021.
//

import SwiftUI

struct TextFieldWrapper: UIViewRepresentable {
    // MARK: - Properties
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType?
    let textField: UITextField = UITextField()

    var isFirstResponder: ((Bool) -> Void)?

    class Coordinator: NSObject, UITextFieldDelegate {
        // MARK: - Properties
        var parent: TextFieldWrapper
        
        
        // MARK: - Initialization
        init(_ parent: TextFieldWrapper) {
            self.parent = parent
        }
        
        
        // MARK: - Class functions
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.isFirstResponder?(false)

            let nextTag = textField.tag + 1
            var parentView = textField.superview
            textField.resignFirstResponder()
            
            while parentView != nil {
                if let field = parentView?.viewWithTag(nextTag) {
                    field.becomeFirstResponder()
                    break
                }
                
                parentView = parentView?.superview
            }
            
            return true
        }
             
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFirstResponder?(true)
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let text = textField.text else { return false }
            
            parent.isFirstResponder?(true)

            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            parent.updateBinding(value: newString)
                        
            return true
        }
    }
    
    
    // MARK: - Custom functions
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let uiView = textField
        uiView.delegate = context.coordinator
        uiView.placeholder = placeholder
        uiView.autocapitalizationType = .none
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.minimumFontSize = 16
        uiView.keyboardType = keyboardType
        uiView.autocorrectionType = .no
        if let contentType = contentType {
            uiView.textContentType = contentType
        }
        
                
        return uiView
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = self.text
        }
    }
    
    func updateBinding(value: String) {
        DispatchQueue.main.asyncAfter(deadline: Dispatch.DispatchTime.now() + 0.01) {
            self.text = value
        }
    }
}
