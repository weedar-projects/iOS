//
//  ProductCartRowView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.03.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import Amplitude

struct ProductCartRowView: View {
    
    @ObservedObject var vm = ProductCartRowVM()
    
    @EnvironmentObject var cartManager: CartManager
    
    var item: ProductModel
    
    @State var quantityField: String
    
    var body: some View{
        ZStack{
            //delete button
            ZStack {
                RoundedRectangle(cornerRadius: 12.0)
                    .fill(Color.col_red_second)
                    .frame(width: 56, height: vm.itemViewHeight, alignment: .center)
                    .overlay(Image("trash_red")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, alignment: .center))
                    
            }
            .hTrailing()
            .onTapGesture {
                if UserDefaults.standard.bool(forKey: "EnableTracking"){
                Amplitude.instance().logEvent("delete_product", withEventProperties: ["category" : item.type.name,
                                                                                        "product_id" : item.id,
                                                                                        "product_price" : item.price.formattedString(format: .percent)])
                }
                
                cartManager.productQuantityInCart(productId: item.id, quantity: .removeAll)
            }
            
            HStack(spacing: 0){
                //Item Image
                WebImage(url: URL(string: "\(BaseRepository().baseURL)/img/" + item.imageLink))
                    .placeholder(
                        Image("Placeholder_Logo")
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: vm.itemViewHeight ,height: vm.itemViewHeight)
                    .mask(Rectangle()
                            .frame(height: vm.itemViewHeight)
                            .cornerRadius(24)
                    )
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Color.col_borders.opacity(0.5), lineWidth: 2))
                
                Spacer()
                
                //product info
                VStack(alignment: .leading){
                    //brand
                    Text(item.brand.name ?? "")
                        .textSecond()
                    Spacer()
                    
                    //title
                    Text(item.name)
                        .textDefault()
                        .padding(.top, 8)
                    
                    Spacer()
                    //bottom info
                    HStack(spacing: 4){
                        
                        //price
                        Text("$\(item.price.formattedString(format: .percent))")
                            .textCustom(.coreSansC65Bold, 16, Color.col_purple_main)
                        
                        //gram
                        Text("\(item.gramWeight.formattedString(format: .gramm))g / \(item.ounceWeight.formattedString(format: .ounce))oz")
                            .textSecond(size: 12)
                    }
                    .padding(.top, 4)
                }
                .padding(.leading, 8)
                .padding(.vertical)
                
                Spacer()
                
                //vertical divider
                Rectangle().fill(Color.col_borders)
                    .frame(width: 1, height: vm.itemViewHeight)
                
                
                //count change
                VStack(spacing: 0){
                    //button plus
                    ZStack{
                        Image("plus_gray")
                            .resizable()
                            .frame(width: 14, height: 14)
                    }
                    .padding(.bottom, 13)
                    .onTapGesture {
                        cartManager.productQuantityInCart(productId: item.id, quantity: .add)
                    }
                    
                    //count view
                    ZStack{
                        RoundedRectangle(cornerRadius: 12.0)
                            .strokeBorder(ColorManager.Catalog.Item.backgroundBlue, lineWidth: 2)
                            .frame(width: 34, height: 49, alignment: .center)
                        
                        Text(quantityField)
                            .textDefault(size: 16)
                    }
                    
                    //button minus
                    Button {
                        cartManager.productQuantityInCart(productId: item.id, quantity: .reduce)

                    } label: {
                        ZStack{
                            //for tap area
                            Color.clear
                                .frame(width: 14, height: 14
                                )
                            Image("minus_gray")
                                .resizable()
                                .frame(width: 14, height: 2)
                        }.padding(.top, 19)
                    }
                    
              
                    
                }.padding(.leading, 12)
            }
            .background(Color.col_white.cornerRadius(12).padding(.trailing, -5))
            .offset(x: vm.offset)
            .gesture(DragGesture().onChanged(vm.onChanged(value:)).onEnded(vm.onEnd(value:)))
        }
    }
}
