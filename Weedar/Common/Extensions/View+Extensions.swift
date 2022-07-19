//
//  View+Extensions.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 17.09.2021.
//

import SwiftUI
import SwiftyBeaver

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
        
    func onUIKitAppear(_ perform: @escaping () -> Void) -> some View {
        self.background(UIKitAppear(action: perform))
    }
}

protocol RemoteActionRepresentable: AnyObject {
    func remoteAction()
}

struct UIKitAppear: UIViewControllerRepresentable {
    let action: () -> Void
    
    func makeUIViewController(context: Context) -> UIAppearViewController {
       let vc = UIAppearViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ controller: UIAppearViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: self.action)
    }
    
    class Coordinator: RemoteActionRepresentable {
        
        var action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        func remoteAction() {
            action()
        }
    }
}

class UIAppearViewController: UIViewController {
    weak var delegate: RemoteActionRepresentable?
    
    override func viewDidLoad() {
        view.addSubview(UILabel())
    }
    override func viewDidAppear(_ animated: Bool) {
        delegate?.remoteAction()
    }
}


//MARK: Extending View to get Screen Bounds...
extension View{
    func getRect()->CGRect{
        return UIScreen.main.bounds
    }
    
    func isSmallIPhone() -> Bool{
        return getRect().height <= 667
    }
}


//MARK: Paddings
extension View{
    //Vertical Center
    func vCenter( )->some View{
        self
            .frame(maxHeight: .infinity,
                   alignment: .center)
    }
    // Vertical Top
    func vTop()->some View{
        self
            .frame(maxHeight: .infinity,
                   alignment: . top)
    }
    // Vertical Bottom
    func vBottom()->some View{
        self
            .frame(maxHeight: .infinity,
                   alignment: .bottom)
    }
    // Horizontal Center
    func hCenter()->some View{
        self
            .frame(maxWidth: .infinity,
                   alignment: .center)
    }
    // Horizontal Leading
    func hLeading( )->some View{
        self
            .frame(maxWidth: .infinity,
                   alignment: .leading)
    }
    // Horizontal Trailing
    func hTrailing()->some View{
        self
            .frame(maxWidth: .infinity,
                   alignment: .trailing)
    }
    
}


extension View {
    func textTitle() -> some View {
        return self.modifier(TextViewModifier(font: .coreSansC65Bold, size: 32, color: Color.col_text_main))
    }
    func textDefault(size: CGFloat = 14) -> some View {
        return self.modifier(TextViewModifier(font: .coreSansC45Regular, size: size, color: Color.col_text_main))
    }
    func textSecond(size: CGFloat = 14) -> some View {
        return self.modifier(TextViewModifier(font: .coreSansC45Regular, size: size, color: Color.col_text_second))
    }
    func textCustom(_ font: CustomFont, _ size: CGFloat, _ color: Color) -> some View {
        return self.modifier(TextViewModifier(font: font, size: size, color: color))
    }
}


extension View{
    
    func getSafeArea()->UIEdgeInsets{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .zero
        }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else{
            return .zero
        }
        
        return safeArea
    }
}

extension View {
  func zoomable(scale: Binding<CGFloat>,
                minScale: CGFloat = 0.5,
                maxScale: CGFloat = 3) -> some View {
    modifier(Zoomable(scale: scale, minScale: minScale, maxScale: maxScale))
  }
}


extension UIImageView {

    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

}

extension UIImage {

    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
          .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    @available(iOS 9.0, *)
    public class func gif(asset: String) -> UIImage? {
        // Create source from assets catalog
        guard let dataAsset = NSDataAsset(name: asset) else {
            print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
            return nil
        }

        return gif(data: dataAsset.data)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
        var lhs = lhs
        var rhs = rhs
        // Check if one of them is nil
        if rhs == nil || lhs == nil {
            if rhs != nil {
                return rhs!
            } else if lhs != nil {
                return lhs!
            } else {
                return 0
            }
        }

        // Swap for modulo
        if lhs! < rhs! {
            let ctp = lhs
            lhs = rhs
            rhs = ctp
        }

        // Get greatest common divisor
        var rest: Int
        while true {
            rest = lhs! % rhs!

            if rest == 0 {
                return rhs! // Found it
            } else {
                lhs = rhs
                rhs = rest
            }
        }
    }

    internal class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        // Fill arrays
        for index in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(image)
            }

            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(index),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        // Calculate full duration
        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
            }()

        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for index in 0..<count {
            frame = UIImage(cgImage: images[Int(index)])
            frameCount = Int(delays[Int(index)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)

        return animation
    }

}


extension View {
    func inExpandingRectangle() -> some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
            self
        }
    }
}
