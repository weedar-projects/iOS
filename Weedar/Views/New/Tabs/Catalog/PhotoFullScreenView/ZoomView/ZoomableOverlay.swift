//
//  ZoomableOverlay.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

// Wraps ZoomableView and exposes it to SwiftUI
struct ZoomableOverlay: UIViewRepresentable {
  @Binding var scale: CGFloat
  @Binding var anchor: UnitPoint
  @Binding var offset: CGSize
  let minScale: CGFloat
  let maxScale: CGFloat

  func makeUIView(context: Context) -> ZoomableView {
    let uiView = ZoomableView(minScale: minScale,
                              maxScale: maxScale,
                              scaleChange: { scale = $0 },
                              anchorChange: { anchor = $0 },
                              offsetChange: { offset = $0 })
    return uiView
  }

  func updateUIView(_ uiView: ZoomableView, context: Context) { }
}
