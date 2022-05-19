//
//  PhoneTextFieldWrapper.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 23.09.2021.
//

import SwiftUI

struct PhoneTextFieldWrapper: UIViewRepresentable {
    // MARK: - Properties
    @Binding var text: String
    var placeholder: String

    var onCommit: (() -> Void)?
    let textField: UITextField = UITextField()

    class Coordinator: NSObject, UITextFieldDelegate {
        // MARK: - Properties
        var parent: PhoneTextFieldWrapper
        
        
        // MARK: - Initialization
        init(_ parent: PhoneTextFieldWrapper) {
            self.parent = parent
        }
        
        
        // MARK: - Class functions
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            let nextTag = textField.tag + 1
            var parentView = textField.superview
            textField.resignFirstResponder()
            
            // locate the next field that has the nextTag and make that the
            // responder.
            while parentView != nil {
                if let field = parentView?.viewWithTag(nextTag) {
                    field.becomeFirstResponder()
                    break
                }
                parentView = parentView?.superview
            }
            
            // Trigger the commit action if given
            self.parent.onCommit?()

            return true
        }
             
        func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField.text?.count == 0 {
                parent.updateBinding(value: "+1")
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard
                let text = textField.text
            else {
                return false
            }

            if string == "" && parent.text.count <= 2 {
                parent.updateBinding(value: "+")
                return false
            }
            
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            parent.updateBinding(value: newString.formattedPhoneNumber)

            return false
        }
    }
    
    
    // MARK: - Custom functions
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let uiView = textField
        uiView.delegate = context.coordinator
        uiView.placeholder = "(000) 000-0000"
        uiView.tag = TextFieldResponder.tagIndex
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // required to avoid the field from growing in size as you type
        
        uiView.keyboardType = .numberPad
        uiView.autocorrectionType = .no
        
        TextFieldResponder.tagIndex += 1
        
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
