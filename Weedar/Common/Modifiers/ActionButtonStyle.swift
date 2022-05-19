//
//  ActionButtonStyle.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 16.09.2021.
//

import SwiftUI

struct ActionButtonStyle: ViewModifier {
    // MARK: - Properties
    let size: CGSize
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let isDisabled: Bool
    
    
    // MARK: - View
    func body(content: Content) -> some View {
        return content
            .frame(height: size.height)
            .background(backgroundColor.opacity(isDisabled ? 0.3 : 1))
            .cornerRadius(cornerRadius)
            .disabled(isDisabled)
    }
}
