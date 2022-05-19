//
//  ShimmerView.swift
//  Weelar
//
//  Created by Galym Anuarbek on 22.10.2021.
//

import SwiftUI

public struct ShimmerView: View {
    
    private struct Constants {
        static let duration: Double = 0.9
        static let minOpacity: Double = 0.5
        static let maxOpacity: Double = 1.0
        static let cornerRadius: CGFloat = 2
    }
    
    @State private var opacity: Double = Constants.minOpacity
    
    public init() {}
    
    public var body: some View {
        ShimmeringView(configuration: .default) {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(Color.lightSecondaryE.opacity(0.05))
        }
    }
}

struct ShimmerConfiguration {
    public let gradient: Gradient
    public let initialLocation: (start: UnitPoint, end: UnitPoint)
    public let finalLocation: (start: UnitPoint, end: UnitPoint)
    public let duration: TimeInterval
    public let opacity: Double
    public static let `default` = ShimmerConfiguration(
        gradient: Gradient(stops: [
          .init(color: .black, location: 0),
          .init(color: .white, location: 0.3),
          .init(color: .white, location: 0.7),
          .init(color: .black, location: 1),
        ]),
        initialLocation: (start: UnitPoint(x: -1, y: 0.5), end: .leading),
        finalLocation: (start: .trailing, end: UnitPoint(x: 2, y: 0.5)),
        duration: 1,
        opacity: 0.6
    )
}

fileprivate struct ShimmeringView<Content: View>: View {
    private let content: () -> Content
    private let configuration: ShimmerConfiguration
    @State private var startPoint: UnitPoint
    @State private var endPoint: UnitPoint
    init(configuration: ShimmerConfiguration, @ViewBuilder content: @escaping () -> Content) {
        self.configuration = configuration
        self.content = content
        _startPoint = .init(wrappedValue: configuration.initialLocation.start)
        _endPoint = .init(wrappedValue: configuration.initialLocation.end)
    }
    var body: some View {
        ZStack {
            content()
            
            LinearGradient(
                gradient: configuration.gradient,
                startPoint: startPoint,
                endPoint: endPoint
            )
            .opacity(configuration.opacity)
            .blendMode(.screen)
            .onUIKitAppear {
                withAnimation(Animation.easeInOut(duration: configuration.duration).repeatForever(autoreverses: false)) {
                    startPoint = configuration.finalLocation.start
                    endPoint = configuration.finalLocation.end
                }
            }
            
        }
    }
}

fileprivate struct ShimmerModifier: ViewModifier {
    let configuration: ShimmerConfiguration
    public func body(content: Content) -> some View {
        ShimmeringView(configuration: configuration) { content }
  }
}


fileprivate extension View {
    func shimmer(configuration: ShimmerConfiguration = .default) -> some View {
        modifier(ShimmerModifier(configuration: configuration))
    }
}
