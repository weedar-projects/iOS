//
//  CartView.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 06.08.2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct CartViewOld: View {
    // MARK: - Properties
    @Binding var selection: SelectedTab
    @Binding var rootIsActive : Bool
    @ObservedObject var viewModel: CartViewModel
    @EnvironmentObject var tabBarViewModel: TabBarViewModel
    @EnvironmentObject var tabBarManager: TabBarManager
    @State private var appeared = false
    @State private var clearCartAlertShow = false
    @State private var isActive : Bool = false
    
    
    
    //    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    
    // MARK: - View
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.productsInCart.isEmpty && !viewModel.flowInProgress {
                    CartViewEmpty(selection: $selection)
                } else {
                    CartViewContent(cartViewModel: viewModel)
                }
            }
            .alert(isPresented: self.$clearCartAlertShow, content: {
                Alert(title: Text("Clear cart"), message: Text("All items will be removed. Are you sure you want to clear your cart?"), primaryButton: .destructive(Text("Clear")) { viewModel.clearCart()} , secondaryButton: .cancel())
            })
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle(Text("Cart"), displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                clearCartAlertShow = true
            }) {
                if !viewModel.productsInCart.isEmpty {
                    Text("Clear cart").foregroundColor(ColorManager.errorColor)
                }
            })
            .onUIKitAppear {
                appeared = true
                tabBarManager.show()
                tabBarViewModel.show()
            }
            .onDisappear {
                appeared = false
            }
            
        }
//        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.rootPresentationMode, self.$isActive)
    } // body
}

struct CartViewEmpty: View {
    // MARK: - Properties
    @Binding var selection: SelectedTab
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    
    var body: some View {
        ZStack{
            HStack{
                Spacer()
                Image("Background_Logo")
            }
            .offset(y: -30)
            VStack {
                Text("Add desired products to cart and come back here when you are done")
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .lineSpacing(4.0)
                    .font(.system(size: 16))
                    .foregroundColor(ColorManager.Catalog.Item.fontGray)
                    .padding(.top, 16)
                
                Spacer()
                
                DefaultButton(text: "Go to catalog",
                              action: {
                    self.selection = .catalog
                    self.presentationMode.wrappedValue.dismiss()
                })
                    .padding(.bottom, 120)
            }
            .padding([.leading, .trailing], 24)
        }
    }
}


// MARK: - CartViewContent
struct CartViewContent: View {
    @State private var activateCheckout : Bool = false
    @State private var navBarHidden = true
    @Environment(\.rootPresentationMode) private var rootPresentationMode: Binding<RootPresentationMode>
    
    @ObservedObject var cartViewModel : CartViewModel
    @State private var isProfile = false
    
    @State var totalConcentrated = 0.0
    @State var totalNonConcentrated = 0.0
    
    @State var priceСorresponds = false
    @State var minOrderPrice: Double = 50
    
    // MARK: - View
    var body: some View {
        
            VStack {
                //            NavigationLink(destination:
                //                            ,
                //                           isActive: self.$activateCheckout) {
                //                EmptyView()
                //            }
                //                .isDetailLink(false)
                //                .navigationBarHidden(navBarHidden)
                //                .onAppear() {
                //                    navBarHidden = false
                //                }
                //
                
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("Only cash is accepted as payment method")
                        .font(.system(size: 14))
                        .foregroundColor(ColorManager.Catalog.Item.fontGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ForEach(cartViewModel.productsInCart) { product in
                            ProductViewOld(cartViewModel: cartViewModel,
                                           item: product.item,
                                           quantityField: String(product.quantity),
                                           quantity: product.quantity, //use cart product
                                           totalConcentrated: $totalConcentrated,
                                           totalNonConcentrated: $totalNonConcentrated
                            )
                        }
                    }
                    
                    VStack {
                        HStack {
                            Text("Order Summary")
                                .foregroundColor(ColorManager.Catalog.Item.fontGray)
                                .bold()
                                .font(.system(size: 14))
                            Spacer()
                        }.padding(.leading, 16)
                            .padding(.top, 24)
                        
                        VStack {
                            HStack{
                                Text("Total weight")
                                    .font(.system(size: 16))
                                Spacer()
                                Text("\(cartViewModel.totalGramWeight().formattedString(format: .gramm))g")
                                    .bold()
                                    .font(.system(size: 16))
                            }.padding([.leading, .trailing], 16)
                                .padding(.top, 16)
                                .padding(.bottom, 12)
                            
                            
                            Divider()
                                .padding([.top, .bottom], 0)
                                .frame(height: 1)
                                .foregroundColor(ColorManager.Catalog.Item.backgroundBlue)
                            HStack{
                                Text("Subtotal")
                                    .font(.system(size: 16))
                                Spacer()
                                Text("$\(cartViewModel.totalPrice().formattedString(format: .percent))")
                                    .font(.system(size: 16))
                                    .bold()
                                    .onChange(of: cartViewModel.totalPrice(), perform: { v in
                                        if v < minOrderPrice{
                                            priceСorresponds = false
                                        }else {
                                            priceСorresponds = true
                                        }
                                    }).onAppear{
                                        if cartViewModel.totalPrice() < minOrderPrice{
                                            priceСorresponds = false
                                        }else {
                                            priceСorresponds = true
                                        }
                                    }
                            }.padding([.leading, .trailing], 16)
                                .padding(.top, 12)
                                .padding(.bottom, 11)
                            
                            Divider()
                                .frame(height: 1)
                                .foregroundColor(ColorManager.Catalog.Item.backgroundBlue)
                            HStack{
                                Text("Delivery")
                                    .font(.system(size: 16))
                                Spacer()
                                Text("$10.00")
                                    .bold()
                                    .font(.system(size: 16))
                            }.padding([.leading, .trailing], 16)
                                .padding(.top, 14)
                                .padding(.bottom, 15)
                        }.background(ColorManager.Catalog.Item.backgroundBlue.cornerRadius(12))
                        
                        VStack {
                            HStack {
                                Text("Total")
                                    .bold()
                                    .font(.system(size: 16))
                                Spacer()
                                Text("$\((cartViewModel.totalPrice()).formattedString(format: .percent))") // Fixed tax
                                    .bold()
                                    .font(.system(size: 16))
                            }.frame(height: 24).padding(.top, 8)
                                .padding([.leading, .trailing], 16)
                                .padding(.top, 12)
                                .padding(.bottom, 15)
                        }.background(ColorManager.Catalog.Item.backgroundBlue.cornerRadius(12))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        //28 226
                        //8 64
                        
                        if totalNonConcentrated > cartViewModel.dailyNonConcentratedAllowance {
                            let nonConcentratedText = "\(cartViewModel.dailyNonConcentratedAllowance)g of Non-concentrated cannabis"
                            
                            Text("You have exceeded your daily allowance:\n\(nonConcentratedText)")
                                .font(.system(size: 14))
                                .lineSpacing(4.0)
                                .foregroundColor(ColorManager.Catalog.Item.fontGray)
                            
                            
                            //                        Text("You have exceeded your daily allowance:\n\(totalConcentrated > cartViewModel.dailyConcentratedAllowance ? concentratedText : "")\(totalNonConcentrated > cartViewModel.dailyNonConcentratedAllowance ? nonConcentratedText : "")")
                            //                            .font(.system(size: 14))
                            //                            .lineSpacing(4.0)
                            //                            .foregroundColor(ColorManager.Catalog.Item.fontGray)
                            
                        } else if totalConcentrated > cartViewModel.dailyConcentratedAllowance {
                            let concentratedText = "\(cartViewModel.dailyConcentratedAllowance)g of Concentrated cannabis\n"
                            
                            Text("You have exceeded your daily allowance:\n\(concentratedText)")
                                .font(.system(size: 14))
                                .lineSpacing(4.0)
                                .foregroundColor(ColorManager.Catalog.Item.fontGray)
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top], 24)
                    
                    if !priceСorresponds{
                        Text("Minimum order amount is 50$.")
                            .font(.system(size: 14))
                            .foregroundColor(ColorManager.Catalog.Item.fontGray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    
                    NavigationLink {
                        DeliveryDetailsViewOld(cartViewModel: cartViewModel,
                                               profileIsActive: Binding<Bool>.constant(false),
                                               isCheckout: true,
                                               navBarHidden: $navBarHidden)
                    } label: {
                        Text("Proceed to checkout")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Color.col_yellow_main)
                    .cornerRadius(12)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                    .disabled(totalConcentrated > cartViewModel.dailyConcentratedAllowance || totalNonConcentrated > cartViewModel.dailyNonConcentratedAllowance || !priceСorresponds)
                    
                }
                .padding(.top, 20)
                .onChange(of: cartViewModel.productsInCart.count) { _ in
                    totalConcentrated = cartViewModel.totalGramWeight(concentrated: true)
                    totalNonConcentrated = cartViewModel.totalGramWeight(concentrated: false)
                    
                }
                .onAppear() {
                    totalConcentrated = cartViewModel.totalGramWeight(concentrated: true)
                    totalNonConcentrated = cartViewModel.totalGramWeight(concentrated: false)
                }
            }.padding([.leading, .trailing], 16)
        
        
        
    } // body
}


// MARK: - ImageUrlView


struct ProductViewOld: View {
    @ObservedObject var cartViewModel : CartViewModel
    
    var item: Product
    @State var quantityField: String
    @State var quantity: Int
    
    @Binding var totalConcentrated: Double
    @Binding var totalNonConcentrated: Double
    
    @State private var offset = CGSize.zero
    @State private var showRemoveItem = false
    
    var body: some View {
        HStack {
            
            WebImage(url: URL(string: "\(BaseRepository().baseURL)/img/" + item.imageLink))
                .placeholder(
                    Image("Placeholder_Logo")
                )
                .resizable()
                .scaledToFit()
                .frame(width: 113, height: 113)
                .mask(Rectangle()
                        .frame(width: 113, height: 113)
                        .cornerRadius(24)
                )
                .cornerRadius(24)
                .overlay(RoundedRectangle(cornerRadius: 24.0)
                            .strokeBorder(ColorManager.Catalog.Item.backgroundBlue, lineWidth: 2))
            
            VStack(alignment: .leading) {
                HStack {
                    /*
                     Text("Category")
                     .font(.system(size: 12))
                     .foregroundColor(ColorManager.Catalog.Item.fontGray)
                     .multilineTextAlignment(.leading)
                     Circle().frame(width: 4, height: 4)
                     .foregroundColor(ColorManager.Catalog.Item.dotGray)
                     */
                    Text(item.brand.name ?? "")
                        .font(.system(size: 12))
                        .foregroundColor(ColorManager.Catalog.Item.fontGray)
                        .multilineTextAlignment(.leading)
                }
                Text(item.name)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6.0)
                    .frame(height: 51)
                    .padding(.top, 2)
                HStack {
                    Text("$\(item.price.formattedString(format: .percent))")
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(ColorManager.Catalog.Item.priceColor)
                        .multilineTextAlignment(.leading)
                    Text("\(item.gramWeight.formattedString(format: .gramm))g / \(item.ounceWeight.formattedString(format: .ounce))oz")
                        .font(.system(size: 12))
                        .foregroundColor(ColorManager.Catalog.Item.fontGray)
                        .multilineTextAlignment(.leading)
                }.padding(.top, 4)
            }
            
            Spacer()
            
            Rectangle().fill(ColorManager.Catalog.Item.backgroundBlue)
                .frame(width: 1, height: 113)
                .padding([.trailing, .leading], 5)
            
            
            VStack{
                Button {
                    let quantity = cartViewModel.changeQuantityOfProduct(id: item.id, quantity: 1)
                    self.quantityField = "\(quantity)"
                } label: {
                    Image("plus_gray")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }// ADD ITEM BUTTO
                .frame(width: 25, height: 25)
                ZStack{
                    RoundedRectangle(cornerRadius: 12.0)
                        .strokeBorder(ColorManager.Catalog.Item.backgroundBlue, lineWidth: 2)
                        .frame(width: 34, height: 49, alignment: .center)
                    Text("\(cartViewModel.getCartProduct(id: item.id)?.quantity ?? 0)")
                        .multilineTextAlignment(.center)
                        .onChange(of: quantityField) {_ in
                            totalConcentrated = cartViewModel.totalGramWeight(concentrated: true)
                            totalNonConcentrated = cartViewModel.totalGramWeight(concentrated: false)
                        }// ITEMS COUNTER
                }
                
                Button {
                    let quantity = cartViewModel.changeQuantityOfProduct(id: item.id, quantity: -1)
                    self.quantityField = "\(quantity)"
                } label: {
                    Image("minus_gray")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }// DELETE ITEM BUTTON
                .frame(width: 25, height: 25)
            }
        }
        //        .contentShape(Rectangle())
        .background(
            HStack() {
                Spacer()
                Button(action: {
                    cartViewModel.changeQuantityOfProduct(id: item.id, quantity: -100)
                }) {
                    RoundedRectangle(cornerRadius: 12.0)
                        .fill(ColorManager.Catalog.Item.backgroundRed)
                        .frame(width: 56, height: 113, alignment: .center)
                        .overlay(Image("trash_red")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, alignment: .center))
                }
            }
                .padding(.trailing, -80)
        )
        .offset(x: offset.width * 0.3)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if showRemoveItem {
                        if gesture.translation.width > 30.0 {
                            showRemoveItem = false
                            withAnimation(.linear(duration: 0.1)) {
                                self.offset = .zero
                            }
                        }
                    } else {
                        if gesture.translation.width < 0.0 {
                            self.offset = gesture.translation
                        }
                    }
                }
                .onEnded { _ in
                    if abs(self.offset.width) > 90 {
                        withAnimation(.linear(duration: 0.1)) {
                            self.offset.width = -80 / 0.3
                        }
                        showRemoveItem = true
                        
                    } else {
                        showRemoveItem = false
                        withAnimation(.linear(duration: 0.1)) {
                            self.offset = .zero
                        }
                    }
                }
        )
    }
}

