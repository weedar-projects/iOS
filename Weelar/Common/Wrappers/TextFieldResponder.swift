//
//  TextFieldResponder.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 23.09.2021.
//

import SwiftUI

struct TextFieldResponder: UIViewRepresentable {
    // MARK: - Properties
    static var tagIndex = 0
    var title: String
    @Binding var text: String
    @Binding var becomeFirstResponder: Bool
    var onCommit: (() -> Void)?
    
    let textField: UITextField = UITextField()

    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextFieldResponder
        
        init(_ parent: TextFieldResponder) {
            self.parent = parent
        }
        
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
            
            // trigger the commit action if given.
            self.parent.onCommit?()

            return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.updateBinding(value: "")
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Check `sms code`
            guard
                string.count == 1
            else {
                if string == "" {
                    parent.updateBinding(value: string)
                    return true
                }
                
                return false
            }
            
            if  let text = textField.text,
                let textRange = Range(range, in: text) {
                let newText = text.replacingCharacters(in: textRange, with: string)
                    
                if newText.count < 2 {
                    parent.updateBinding(value: newText)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                        if newText.count == 1 {
                            if textField.tag == 6 {
                                self.parent.onCommit?()
                            } else {
                                _ = self.textFieldShouldReturn(textField)
                            }
                        }
                    }
                } else {
                    parent.updateBinding(value: text)
                    return false
                }
            }
            
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
        uiView.placeholder = title
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
        uiView.text = self.text

        if self.becomeFirstResponder {
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
                self.becomeFirstResponder = false
            }
        }
    }
    
    func updateBinding(value: String) {
        DispatchQueue.main.asyncAfter(deadline: Dispatch.DispatchTime.now() + 0.01) {
            self.text = value
        }
    }
}
