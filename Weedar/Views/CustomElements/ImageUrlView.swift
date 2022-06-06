//
//  ImageUrlView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct ImageUrlView: View {
    @ObservedObject var remoteImageModel: RemoteImageModel
    
    let width: CGFloat
    @State var url = ""
    init(url: String?, width: CGFloat = 113) {
        self.width = width
        remoteImageModel = RemoteImageModel(imageUrl: url)
    }
    
    var body: some View {
        VStack {
            if let image = remoteImageModel.displayImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width)
                    .scaleEffect(0.8)
            } else {
                Image("Product_Detail_Placeholder")
                    .resizable()
                    .frame(width: width, height: width)
            }
        }
    }
}
