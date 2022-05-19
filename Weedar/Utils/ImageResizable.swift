//
//  ImageExtension.swift
//  Weelar
//
//  Created by vtsyomenko on 29.09.2021.
//

import SwiftUI

class ImageResizable {
    @State var width: CGFloat = 0
    @State var height: CGFloat = 0
    
    func image(_ name: String) -> UIImage {
        let image = UIImage(named: name)!
        let width = image.size.width
        let height = image.size.height

        DispatchQueue.main.async {
            if width > height {
                // Landscape image
                // Use screen width if < than image width
                self.width = width > UIScreen.main.bounds.width ? UIScreen.main.bounds.width : width
                // Scale height
                self.height = self.width/width * height
            } else {
                // Portrait
                // Use 600 if image height > 600
                self.height = height > 600 ? 600 : height
                // Scale width
                self.width = self.height/height * width
            }
        }
        return image
    }
}
