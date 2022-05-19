//
//  TextViewWrapper.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 22.09.2021.
//

import SwiftUI

class AppTextView: UITextView, UITextViewDelegate {
    // MARK: - Properties
    var viewModel: VerifyIdentityVM?


    // MARK: - Class functions
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.9) {
            self.viewModel?.isPrivacyPolicy = URL.absoluteString == "policy"
            self.viewModel?.isTermsConditions = URL.absoluteString == "terms"
            self.viewModel?.isWebViewShow = self.viewModel?.isTermsConditions ?? false || self.viewModel?.isPrivacyPolicy ?? false
        }
        
        return false
    }
}

struct TextViewWrapper: UIViewRepresentable {
    // MARK: - Properties
    @Binding var text: NSMutableAttributedString
    @StateObject var vm: VerifyIdentityVM

    
    // MARK: - Functions
    func makeUIView(context: Context) -> AppTextView {
        let view = AppTextView()

        view.viewModel                  =   vm
        view.dataDetectorTypes          =   .link
        view.isEditable                 =   false
        view.isSelectable               =   true
        view.delegate                   =   view
        view.isUserInteractionEnabled   =   true

        return view
    }

    func updateUIView(_ uiView: AppTextView, context: Context) {
        uiView.attributedText = text
    }
}
