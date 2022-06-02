//
//  PasswordTextFieldWrapper.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 14.10.2021.
//

import SwiftUI

struct PasswordTextFieldWrapper: UIViewRepresentable {
    // MARK: - Properties
    @Binding var text: String
    @Binding var isSecureTextEntry: Bool
    @Binding var becomeFirstResponder: Bool

    static var tagIndex = 1
    var placeholder: String

    let textField: UITextField = UITextField()

    var returnHandler: (() -> Void)?
    var editingHandler: (() -> Void)?

    class Coordinator: NSObject, UITextFieldDelegate {
        // MARK: - Properties
        var parent: PasswordTextFieldWrapper
        
        
        // MARK: - Initialization
        init(_ parent: PasswordTextFieldWrapper) {
            self.parent = parent
        }
        
        
        // MARK: - Class functions
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.returnHandler?()

            let nextTag = 1
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
            parent.editingHandler?()
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard
                let text = textField.text
            else {
                return false
            }
                        
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            parent.updateBinding(value: newString)
            parent.editingHandler?()

            return true
        }
    }
    
    
    // MARK: - Custom functions
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let uiTextField = textField
        uiTextField.delegate = context.coordinator
        uiTextField.placeholder = placeholder
        uiTextField.tag = 0
        uiTextField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiTextField.minimumFontSize = 16
        uiTextField.keyboardType = .emailAddress
        uiTextField.autocorrectionType = .no
        
        uiTextField.isSecureTextEntry = isSecureTextEntry
    
        return uiTextField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = self.text
        }
        
        if becomeFirstResponder {
            _ = withAnimation {
                textField.becomeFirstResponder()
            }
        }
    }
    
    func updateBinding(value: String) {
        DispatchQueue.main.asyncAfter(deadline: Dispatch.DispatchTime.now() + 0.01) {
            self.text = value
        }
    }
}
