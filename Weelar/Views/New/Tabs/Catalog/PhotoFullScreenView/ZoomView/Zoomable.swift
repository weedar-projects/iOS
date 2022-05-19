//
//  Zoomable.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

// Applies ZoomableOverlay to intercept gestures and apply scale,
// anchor point and offset
struct Zoomable: ViewModifier {
  @Binding var scale: CGFloat
  @State private var anchor: UnitPoint = .center
  @State private var offset: CGSize = .zero
  let minScale: CGFloat
  let maxScale: CGFloat

  init(scale: Binding<CGFloat>,
       minScale: CGFloat,
       maxScale: CGFloat) {
    _scale = scale
    self.minScale = minScale
    self.maxScale = maxScale
  }

  func body(content: Content) -> some View {
    content
      .scaleEffect(scale, anchor: anchor)
      .offset(offset)
      .animation(.spring()) // looks more natural
      .overlay(ZoomableOverlay(scale: $scale,
                               anchor: $anchor,
                               offset: $offset,
                               minScale: minScale,
                               maxScale: maxScale))
      .gesture(TapGesture(count: 2).onEnded {
        if scale != 1 { // reset the scale
          scale = clamp(1, minScale, maxScale)
          anchor = .center
          offset = .zero
        } else { // quick zoom
          scale = clamp(2, minScale, maxScale)
        }
      })
  }
}
