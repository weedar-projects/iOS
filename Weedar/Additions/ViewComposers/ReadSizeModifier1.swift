////
////  ReadSizeModifier.swift
////  Weelar
////
//
//import SwiftUI
//
//public extension View {
//
//  func readSize(perform: @escaping (CGSize) -> Void) -> some View {
//    background(
//      GeometryReader { geometry in
//        Color.clear
//          .preference(key: ReadSizePreferenceKey.self, value: geometry.frame(in: .local))
//      }
//      .onPreferenceChange(ReadSizePreferenceKey.self) { perform($0.size) }
//    )
//  }
//
//  func readSizeAsync(width: Binding<CGFloat>? = nil, height: Binding<CGFloat>? = nil) -> some View {
//    background(
//      GeometryReader { geometry -> Color in
//        if let width = width, width.wrappedValue != geometry.size.width {
//          let newWidth = geometry.size.width
//          DispatchQueue.main.async {
//            width.wrappedValue = newWidth
//          }
//        }
//        if let height = height, height.wrappedValue != geometry.size.height {
//          let newHeight = geometry.size.height
//          DispatchQueue.main.async {
//            height.wrappedValue = newHeight
//          }
//        }
//        return Color.clear
//      }
//    )
//  }
//
//}
//
//private struct ReadSizePreferenceKey: PreferenceKey {
//
//  static let defaultValue = CGRect.zero
//
//  static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
//    value = nextValue()
//  }
//
//}
