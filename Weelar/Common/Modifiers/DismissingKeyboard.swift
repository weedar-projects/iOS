//
//  DismissingKeyboard.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 28.09.2021.
//

import SwiftUI

struct DismissingKeyboard: ViewModifier {
    // MARK: - View
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow =
                UIApplication
                    .shared
                    .connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                
                keyWindow?.endEditing(true)
            }
    }
}
