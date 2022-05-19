//
//  SwiftUIView.swift
//  Weelar
//

import Combine
import SwiftUI

struct OrderPickerView: View {
    @ObservedObject var ordersViewModel: OrderViewModel
    @Binding var selectedOrder: OrderResponseModel
    @Binding var pickerIsPresented: Bool
    var body: some View {
        ScrollView {
            Text("Choose an order")
                .modifier(
                    TextModifier(font: .coreSansC65Bold,
                                 size: 26,
                                 foregroundColor: Color.white,
                                 opacity: 1)
                )
                .padding()
            ForEach(ordersViewModel.orders, id: \.id) { order in
                Button(
                    action: {
                        selectedOrder = order
                        pickerIsPresented = false
                    },
                    label: { rowLabel(for: order) }
                )
            }
            .padding()
        }
        .background(Color.lightOnSurfaceB)
        //.ignoresSafeArea()
    }
    
    func rowLabel(for order: OrderResponseModel) -> some View {
        HStack {
            Text("#\(order.number)")
                .modifier(
                    TextModifier(font: .coreSansC65Bold,
                                 size: 20,
                                 foregroundColor: order.id == selectedOrder.id ? Color.yellow : Color.white,
                                 opacity: 1)
                )
            Spacer()
            if let orderState = order.state.orderState {
            Text(orderState.title)
                .modifier(
                    TextModifier(font: .coreSansC65Bold,
                                 size: 14,
                                 foregroundColor: Color.white,
                                 opacity: 1)
                )
            
                .padding(6)
                .background(orderState.color)
                .cornerRadius(10)
            }
        }
    }
}

struct OrderPickerView_Previews: PreviewProvider {
    static var previews: some View {
        OrderPickerView(ordersViewModel: OrderViewModel(), selectedOrder: .constant(OrderResponseModel.mock(23)), pickerIsPresented: .constant(true))
    }
}

