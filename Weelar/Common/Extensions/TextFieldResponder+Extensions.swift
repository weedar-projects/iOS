//
//  TextFieldResponder+Extensions.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 23.09.2021.
//

import SwiftUI

extension TextFieldResponder {
    func keyboardType(_ kbd: UIKeyboardType) -> TextFieldResponder {
        textField.keyboardType = kbd
        return self
    }
    
    func isSecure(_ secure: Bool) -> TextFieldResponder {
        textField.isSecureTextEntry = secure
        return self
    }
    
    func returnKeyType(_ type: UIReturnKeyType) -> TextFieldResponder {
        textField.returnKeyType = type
        return self
    }
    
    func autocapitalization(_ autocap: UITextAutocapitalizationType) -> TextFieldResponder {
        textField.autocapitalizationType = autocap
        return self
    }
    
    func autocorrection(_ autocorrect: UITextAutocorrectionType) -> TextFieldResponder {
        textField.autocorrectionType = autocorrect
        return self
    }
}
