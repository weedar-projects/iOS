//
//  MyOrderView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 31.03.2022.
//

import SwiftUI
import SkeletonUI

struct MyOrderView: View {
    @StateObject var vm = MyOrderVM()
    @State var id: Int
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @ObservedObject var deepLinksManager = DeepLinks.shared
    
    @Environment(\.redactionReasons) var redactionReasons
    var body: some View {
        NavigationView{
            
            ZStack{
                Color.col_white
                VStack{
                    //main scroll
                    ScrollView(.vertical, showsIndicators: false) {
                        
                        Text("List of items")
                            .textCustom(.coreSansC65Bold, 14, Color.col_text_second)
                            .padding(.top, 24)
                            .padding(.leading, 35)
                            .hLeading()
                        
                        //items view
                        VStack(spacing: 0){
                            ForEach(vm.orderProducts, id: \.self) { product in
                                VStack{
                                ProductCompactRow(data: product)
                                        
                                CustomDivider()
                                    .opacity(vm.orderProducts.last != product ? 1 : 0)
                                }
                                .background(Color.col_bg_second)
                                .cornerRadius(radius: 12, corners: vm.orderProducts.first == product ? [.topLeft, .topRight] : [.allCorners])
                                .cornerRadius(radius: 12, corners: vm.orderProducts.last == product ? [.bottomLeft, .bottomRight] : [.allCorners])
                            }
                            
                            .padding(.horizontal, 24)
                            .customRedacted(reason: vm.order?.name.isEmpty ?? true ? .shimer : nil)
                            
                            //Pricing view
                            CalculationPriceView(data: $vm.orderDetailsReview)
                                .padding(.top, 24)
                                .padding(.horizontal, 24)
                                .customRedacted(reason: vm.order?.name.isEmpty ?? true ? .shimer : nil)
                            
                            Text("Delivery details")
                                .textCustom(.coreSansC65Bold
                                            , 14, Color.col_text_second)
                                .padding(.top, 24)
                                .padding(.leading, 35)
                                .hLeading()
                            
                            //delivery user data
                            VStack(alignment: .leading,spacing: 10){
                                Text("\(vm.order?.name ?? "")")
                                    .textDefault()
                                Text("\(vm.order?.addressLine1 ?? "")")
                                    .textDefault()
                                Text("\(vm.order?.zipCode ?? "")")
                                    .textDefault()
                                Text("\(vm.order?.phone ?? "")")
                                    .textDefault()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.col_bg_second.cornerRadius(12))
                            .padding(.horizontal, 24)
                            .padding(.top,8)
                            .customRedacted(reason: vm.order?.name.isEmpty ?? true ? .shimer : nil)

                        }
                        .padding(.top, 8)
                        
                    }
                }
                
            }
            .navigationTitle(vm.navTitle)
            
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            deepLinksManager.showDeeplinkView = false
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image("xmark")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .padding()
                        }
                    }
                }
        }
        .onAppear {
            vm.getOrderDetails(id)
        }
        .onChange(of: vm.order?.id ?? 0) { id in
            setNavTitle(orderID: id)
        }
    }
    
    func setNavTitle(orderID: Int){
        vm.navTitle = orderID == 0 ? "" : "Order #\(orderID)"
    }
}


public struct CustomShimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration = 1.5
    var bounce = false

    public func body(content: Content) -> some View {
        content
            .modifier(CustomAnimatedMask(phase: phase)
                        .animation(
                Animation.linear(duration: duration)
                    .repeatForever(autoreverses: bounce)
            ))
            .onAppear { phase = 0.8 }
    }

    /// An animatable modifier to interpolate between `phase` values.
    struct CustomAnimatedMask: AnimatableModifier {
        var phase: CGFloat = 0

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            content
               
                .mask(CustomGradientMask(phase: phase).scaleEffect(3))
                .foregroundColor(Color.col_borders)
        }
    }

    /// A slanted, animatable gradient between transparent and opaque to use as mask.
    /// The `phase` parameter shifts the gradient, moving the opaque band.
    struct CustomGradientMask: View {
        let phase: CGFloat
        let centerColor = Color.red
        let edgeColor = Color.red.opacity(0.3)

        var body: some View {
            LinearGradient(gradient:
                Gradient(stops: [
                    .init(color: Color.white, location: phase),
                    .init(color: Color.white.opacity(0.1), location: phase + 0.1),
                    .init(color: Color.white, location: phase + 0.2)
                ]), startPoint: .leading, endPoint: .trailing)
        }
    }
}

public extension View {
    /// Adds an animated shimmering effect to any view, typically to show that
    /// an operation is in progress.
    /// - Parameters:
    ///   - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
    ///   - duration: The duration of a shimmer cycle in seconds. Default: `1.5`.
    ///   - bounce: Whether to bounce (reverse) the animation back and forth. Defaults to `false`.
    @ViewBuilder func customShimmering(
        active: Bool = true, duration: Double = 1.5, bounce: Bool = false
    ) -> some View {
        if active {
            modifier(CustomShimmer(duration: duration, bounce: bounce))
        } else {
            self
        }
    }
}

public enum RedactionReason {

  case placeholder
  case confidential
  case shimer
}

// MARK: Step 2: Define Modifiers
struct Placeholder: ViewModifier {
  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(iOS 14.0, *) {
      content.redacted(reason: RedactionReasons.placeholder)
    } else {
      content
        .accessibility(label: Text("Placeholder"))
        .opacity(0)
        .overlay(
          RoundedRectangle(cornerRadius: 2)
            .fill(Color.col_borders)
            .padding(.vertical, 4.5)
        )
    }
  }
}

struct Confidential: ViewModifier {
  func body(content: Content) -> some View {
    content
      .accessibility(label: Text("Confidential"))
      .opacity(0)
      .overlay(
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.col_borders)
          .padding(.vertical, 4.5)
    )
  }
}

struct Blurred: ViewModifier {
  func body(content: Content) -> some View {
    content
      .accessibility(label: Text("Blurred"))
      .blur(radius: 4)
  }
}

struct Shimered: ViewModifier {
  func body(content: Content) -> some View {
    content
      .accessibility(label: Text("Blurred"))
      .customShimmering()
      
//      .overlay(
//        ShimmerView()
//
//            .padding(.horizontal, 24)
//            .cornerRadius(12)
//      )
  }
}

// MARK: Step 3: Define RedactableView
struct RedactableView: ViewModifier {
  let reason: RedactionReason?

  @ViewBuilder
  func body(content: Content) -> some View {
    switch reason {
    case .placeholder:
      content
        .modifier(Placeholder())
    case .confidential:
      content
        .modifier(Confidential())
    case .shimer:
      content
            
        .modifier(Shimered())
    case nil:
      content
    
    }
  }
}

// MARK: Step 4: Define View Extension
extension View {
  func customRedacted(reason: RedactionReason?) -> some View {
      self
        .modifier(RedactableView(reason: reason))
  }
}


