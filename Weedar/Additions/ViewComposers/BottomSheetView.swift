//
//  BottomSheetView.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 05.08.2021.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    let content: Content
    var backgroundColor = Color.white
    var blur: CGFloat = 0.0
    var isNft: Bool = false

    init(blur: CGFloat = 0.0, backgroundColor: Color = Color.white, isNft: Bool ,@ViewBuilder content: () -> Content) {
        self.content = content()
        self.blur = blur
        self.backgroundColor = backgroundColor
        self.isNft = isNft
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                content
                    .padding(.bottom, 16)
            }
            .background(backgroundColor)
            .background(blur > 0.0 ? Blur(style: .systemUltraThinMaterialDark) : Blur(style: .extraLight))
             .cornerRadius(radius: 24, corners: [.topRight, .topLeft])
             .edgesIgnoringSafeArea(.bottom)
             .ignoresSafeArea(.keyboard)
             .padding(.top, 8)
             .overlay(
                 //nftbanner
             Image("nft_circle")
                 .resizable()
                 .frame(width: 87, height: 87)
                 .padding(.leading, 24)
                 .offset(x: 0, y: -55)
                 .opacity(isNft ? 1 : 0)
                 ,alignment: .topLeading)
        }
    }
}

// TODO: move
struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    struct CornerRadiusShape: Shape {

        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}
