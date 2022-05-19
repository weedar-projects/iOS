//
//  GifImage.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 12.03.2022.
//

import SwiftUI
import WebKit
import FLAnimatedImage

struct GifImage: UIViewRepresentable {
    let animatedView = FLAnimatedImageView()
    
    private let name: String
    
    init(fileName: String) {
        self.name = fileName
    }

    func makeUIView(context: UIViewRepresentableContext<GifImage>) -> UIView {
        let view = UIView()
        
        let path: String = Bundle.main.path(forResource: name, ofType: "gif")!
        let url = URL(fileURLWithPath: path)
        let gifData = try! Data(contentsOf: url)
        
        let gif = FLAnimatedImage(gifData: gifData)
        animatedView.animatedImage = gif
        
        animatedView.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(animatedView)
        
        NSLayoutConstraint.activate([
            animatedView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animatedView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context:  UIViewRepresentableContext<GifImage>) {}

}
