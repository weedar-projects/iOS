//
//  ProductCatalogRowView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 17.03.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import Amplitude

struct ProductCatalogRowView: View {
    
    @StateObject var vm = ProductCatalogRowVM()
    
    @EnvironmentObject var cartManager: CartManager
    
    var item: ProductModel

    @Binding var productInCartAnimation: Bool
    
    var body: some View {
        
        HStack(spacing: 0){
            
            //Item Image
            WebImage(url: URL(string: "\(BaseRepository().baseURL)/img/" + item.imageLink))
                .placeholder(
                    Image("Placeholder_Logo")
                )
                .resizable()
                .scaledToFit()
                .frame(width: vm.itemViewHeight, height: vm.itemViewHeight)
                .mask(Rectangle()
                        .frame(height: vm.itemViewHeight)
                        .cornerRadius(24)
                )
                .padding(5)
                .cornerRadius(24)
                .overlay(RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.col_borders
                                            .opacity(0.5), lineWidth: 2)
                )
                
            Spacer()
            
            //product info
            VStack(alignment: .leading){
                
                //brand
                Text(item.brand.name ?? "")
                    .textCustom(.coreSansC45Regular, 12, Color.col_text_second)
                    .padding(.top, 5)
                
                Spacer()
                
                VStack(alignment: .leading){
                    //title
                    Text(item.name)
                        .textDefault()
                    Spacer()
                    
                    HStack(spacing: 4){
                        Text("THC: \(item.thc.formattedString(format: .int))%")
                            .textCustom(.coreSansC65Bold, 12, Color.col_pink_main)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(
                                ZStack{
                                    Color.col_red_second
                                    
                                    Capsule()
                                        .fill(Color.col_white)
                                        .blur(radius: 9)
                                        .scaleEffect(1.3)
                                    
                                    Capsule()
                                        .fill(Color.col_white)
                                        .blur(radius: 4)
                                        .scaleEffect(0.4)
                                        .opacity(0.5)
                                        
                                }
                                .clipShape(Capsule())
                            )
                        
                        Text("\(item.strain.name)")
                            .textCustom(.coreSansC65Bold, 12, Color.col_blue_main)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.col_blue_second.cornerRadius(25))
                    }
                }.padding(.vertical, 8)
                
                //bottom info
                HStack(spacing: 4){
                    
                    //price
                    Text("$\(item.price.formattedString(format: .percent))")
                        .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    
                    //gram
                    Text("\(item.gramWeight.formattedString(format: .gramm))g / \(item.ounceWeight.formattedString(format: .ounce))oz")
                        .textSecond(size: 12)
                }
            }
            .padding(.leading, 8)
            
            Spacer()
            
            ZStack{
                if vm.productAddToCart{
                    successButton()
                }else{
                    addButton()
                }
            }
            .disabled(vm.productAddToCart)
            .onChange(of: vm.productAddToCart) { newValue in
                productInCartAnimation = newValue
            }
            .onTapGesture {
                cartManager.productQuantityInCart(productId: item.id, quantity: .add)
                vm.product_qty += 1
                if UserDefaults.standard.bool(forKey: "EnableTracking"){

                Amplitude.instance().logEvent("add_cart_catalog", withEventProperties: ["category" : item.type.name,
                                                                                        "product_id" : item.id,
                                                                                        "product_qty" : vm.product_qty,
                                                                                        "product_price" : item.price.formattedString(format: .percent)])
                }
                vm.chageAddButtonState()
            }
        }
        
    }
    
    @ViewBuilder
    func addButton() -> some View {
        ZStack{
            RadialGradient(colors: [Color.col_gradient_blue_second,
                                    Color.col_gradient_blue_first],
                           center: .center,
                           startRadius: 0,
                           endRadius: 25)
            
            Image("icon_plus")
                .colorInvert()
            
        }
        .clipShape(Circle())
        .frame(width: 40, height: 40)
        
    }
    @ViewBuilder
    func successButton() -> some View {
        
        ZStack{
            RadialGradient(colors: [Color.col_gradient_green_second,
                                    Color.col_gradient_green_first],
                           center: .center,
                           startRadius: 0,
                           endRadius: 25)
            Image("checkmark")
                        .resizable()
                        .foregroundColor(Color.col_black)
                        .scaledToFit()
                        .frame(width: 14, height: 14)
        }
        .clipShape(Circle())
        .frame(width: 40, height: 40)
    }
}
