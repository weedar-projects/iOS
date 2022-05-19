//
//  LineDelayedView.swift
//  Weelar
//
//  Created by Galym Anuarbek on 03.11.2021.
//

import SwiftUI

protocol LineDelayedView: DelayedViewProtocol {
    var presentationMode_: Binding<PresentationMode> { get }
    var title: String { get set }
}

extension LineDelayedView {
    
    var loader: some View {
        VStack() {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode_.wrappedValue.dismiss()
                }, label: {
                    Image("xmark")
                })
                .frame(width: 24, height: 24)
                .padding(EdgeInsets(top: 43.5, leading: 0, bottom: 9.5, trailing: 9.5))
            }
            .frame(alignment: .top)
            HStack {
                Text(title)
                    .font(.custom(CustomFont.coreSansC65Bold.rawValue, size: 32))
                    .padding(EdgeInsets(top: 12, leading: 24, bottom: 8, trailing: 24))
                Spacer()
            }
            HStack {
                LineLoaderView(progressColor: ColorManager.Profile.lilacColor)
                    .frame(height: 4, alignment: .center)
                    .padding(EdgeInsets(top: 16, leading: 24, bottom: 0, trailing: 24))
            }
            Spacer()
        }
    }
}


struct NewLineLoaderView: View {
    var body: some View {
        VStack() {
            HStack {
                LineLoaderView(progressColor: ColorManager.Profile.lilacColor)
                    .frame(height: 4, alignment: .center)
                    .padding(EdgeInsets(top: 16, leading: 24, bottom: 0, trailing: 24))
            }
            Spacer()
        }
    }
}

