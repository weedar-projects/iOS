//
//  ButtonStyles.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 05.08.2021.
//

import SwiftUI

enum ButtonStyles {
    
    case field
    case secondary

    struct ButtonFieldStyle: ViewModifier {

        var isDisabled: Bool = true
        var activeColor = ColorManager.Buttons.buttonActiveColor
        
        func body(content: Content) -> some View {
            return content
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 48)
                .background(isDisabled ? ColorManager.Buttons.buttonInactiveColor : activeColor)
                    .cornerRadius(10.0)
                    .disabled(isDisabled)
        }
    }
    
    struct SecondaryButtonStyle: ViewModifier {

        var isDisabled: Bool = true
        var activeColor = ColorManager.Buttons.buttonSecondaryColor
        
        func body(content: Content) -> some View {
            return content
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 48)
                .background(isDisabled ? ColorManager.Buttons.buttonInactiveColor : activeColor)
                    .cornerRadius(10.0)
                    .disabled(isDisabled)
        }
    }

}

struct DefaultButton: View {
    var text: String
    var isDisabled: Bool
    var style: ButtonStyles
    var action: () -> Void
    
    init(text: String, isDisabled: Bool = false, style: ButtonStyles = .field, action: @escaping () -> Void) {
        self.text = text
        self.action = action
        self.isDisabled = isDisabled
        self.style = style
    }
    
    var body : some View {
        Button(action: action, label: {
            Text(text)
                .font(.custom("CoreSansC-65Bold", fixedSize: 16))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44)
                .foregroundColor(isDisabled ? ColorManager.Buttons.buttonTextInactiveColor : style == .field ? Color.black : Color.white)
        })
            .if(style == .field) {
                $0
                    .modifier(ButtonStyles.ButtonFieldStyle(isDisabled: isDisabled))
            }
            .if(style == .secondary) {
                $0
                    .modifier(ButtonStyles.SecondaryButtonStyle(isDisabled: isDisabled))
            }
            .disabled(isDisabled)
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
