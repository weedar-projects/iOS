//
//  LinkedText.swift
//  Weelar
//
//  Created by vtsyomenko on 26.08.2021.
//

import SwiftUI
import Foundation

private let linkDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
enum Component {
        case text(String)
        case link(String, URL)
    }

struct LinkColoredText: View {
    
    let text: String
    let components: [Component]
    
    init(text: String, components: [Component], links: [LinkHelper]) {
        self.text = text
        self.components = components
    }

    var body: some View {
        components.map { component in
            switch component {
            case .text(let text):
                return Text(verbatim: text).fontStyle(.body)
            case .link(let text, _):
                return Text(verbatim: text).underline().fontStyle(.body)
            }
        }.reduce(Text(""), +)
    }
}
struct LinkHelper {
    var link:String
    var textCheckingResult: NSTextCheckingResult
}

struct LinkedText: View {
    let text: String
    var components: [Component] = []
    var links: [LinkHelper]
    let termsAndConditions = "\(BaseRepository().baseURL)/termsAndConditions"
    let privacyPolicy = "\(BaseRepository().baseURL)/privacyPolicy"
    init (_ text: String) {
        self.text = text
        let nsText = text as NSString

        let regex = try! NSRegularExpression(pattern: "Terms & Conditions | Privacy Policy", options: .caseInsensitive)
        
        var matches = regex.matches(in: text, options: [], range: NSMakeRange(0, text.count)) as Array<NSTextCheckingResult>
        links = [LinkHelper(link: termsAndConditions, textCheckingResult: matches.first!),
                     LinkHelper(link: privacyPolicy, textCheckingResult: matches.last!)]
        
        components.append(.text("I accept "))
        components.append(.link("Terms & Conditions", URL(string: termsAndConditions)!))
        components.append(.text(" and "))
        components.append(.link("Privacy Policy", URL(string: privacyPolicy)!))
        components.append(.text(" of the Service"))
    }
    
    var body: some View {
        LinkColoredText(text: text,components: components,links: links)
            .font(.body) // enforce here because the link tapping won't be right if it's different
            .overlay(LinkTapOverlay(text: text, components: components, links: links))
    }
}

private struct LinkTapOverlay: UIViewRepresentable {
    let text: String
    let components: [Component]
    let links: [LinkHelper]
    
    func makeUIView(context: Context) -> LinkTapOverlayView {
        let view = LinkTapOverlayView()
        view.textContainer = context.coordinator.textContainer
        
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapLabel(_:)))
        tapGesture.delegate = context.coordinator
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: LinkTapOverlayView, context: Context) {
        let attributedString = NSAttributedString(string: text, attributes: [.font: UIFont.preferredFont(forTextStyle: .body)])
        context.coordinator.textStorage = NSTextStorage(attributedString: attributedString)
        context.coordinator.textStorage!.addLayoutManager(context.coordinator.layoutManager)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let overlay: LinkTapOverlay
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        var textStorage: NSTextStorage?
        
        init(_ overlay: LinkTapOverlay) {
            self.overlay = overlay
            
            textContainer.lineFragmentPadding = 0
            textContainer.lineBreakMode = .byWordWrapping
            textContainer.maximumNumberOfLines = 0
            layoutManager.addTextContainer(textContainer)
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            let location = touch.location(in: gestureRecognizer.view!)
            let result = link(at: location)
            return result != nil
        }
        
        @objc func didTapLabel(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view!)
            guard let result = link(at: location) else {
                return
            }

            guard let url = URL(string: result.link) else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        private func link(at point: CGPoint) -> LinkHelper? {
            guard !overlay.links.isEmpty else {
                return nil
            }

            let indexOfCharacter = layoutManager.characterIndex(
                for: point,
                in: textContainer,
                fractionOfDistanceBetweenInsertionPoints: nil
            )
            return overlay.links.first { $0.textCheckingResult.range.contains(indexOfCharacter) }
        }
    }
}

private class LinkTapOverlayView: UIView {
    var textContainer: NSTextContainer!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        var newSize = bounds.size
        newSize.height += 20 // need some extra space here to actually get the last line
        textContainer.size = newSize
    }
}
