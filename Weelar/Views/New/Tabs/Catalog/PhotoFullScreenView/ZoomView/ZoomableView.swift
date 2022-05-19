//
//  ZoomableView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

// UIView that relies on UIPinchGestureRecognizer to detect scale, anchor point and offset
class ZoomableView: UIView {
  let minScale: CGFloat
  let maxScale: CGFloat
  let scaleChange: (CGFloat) -> Void
  let anchorChange: (UnitPoint) -> Void
  let offsetChange: (CGSize) -> Void

  private var scale: CGFloat = 1 {
    didSet {
      scaleChange(scale)
    }
  }
  private var anchor: UnitPoint = .center {
    didSet {
      anchorChange(anchor)
    }
  }
  private var offset: CGSize = .zero {
    didSet {
      offsetChange(offset)
    }
  }

  private var isPinching: Bool = false
  private var startLocation: CGPoint = .zero
  private var location: CGPoint = .zero
  private var numberOfTouches: Int = 0
  // track the previous scale to allow for incremental zooms in/out
  // with multiple sequential pinches
  private var prevScale: CGFloat = 0

  init(minScale: CGFloat,
       maxScale: CGFloat,
       scaleChange: @escaping (CGFloat) -> Void,
       anchorChange: @escaping (UnitPoint) -> Void,
       offsetChange: @escaping (CGSize) -> Void) {
    self.minScale = minScale
    self.maxScale = maxScale
    self.scaleChange = scaleChange
    self.anchorChange = anchorChange
    self.offsetChange = offsetChange
    super.init(frame: .zero)
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
    pinchGesture.cancelsTouchesInView = false
    addGestureRecognizer(pinchGesture)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  @objc private func pinch(gesture: UIPinchGestureRecognizer) {
    switch gesture.state {
    case .began:
      isPinching = true
      startLocation = gesture.location(in: self)
      anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
      numberOfTouches = gesture.numberOfTouches
      prevScale = scale
    case .changed:
      if gesture.numberOfTouches != numberOfTouches {
        let newLocation = gesture.location(in: self)
        let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
        startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)
        numberOfTouches = gesture.numberOfTouches
      }
      scale = clamp(prevScale * gesture.scale, minScale, maxScale)
      location = gesture.location(in: self)
      offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
    case .possible, .cancelled, .failed:
      isPinching = false
      scale = 1.0
      anchor = .center
      offset = .zero
    case .ended:
      isPinching = false
    @unknown default:
      break
    }
  }
}
