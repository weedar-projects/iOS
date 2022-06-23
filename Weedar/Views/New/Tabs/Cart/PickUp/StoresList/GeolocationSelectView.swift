//
//  GeolocationSelectView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.06.2022.
//

import SwiftUI

struct GeolocationSelectView: View {
    @Binding var selectedRadius: Double
    
    var radiusValues: [Double] = [5, 10, 15, 20]
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View{
        VStack(alignment: .leading){
            ForEach(radiusValues, id: \.self) { value in
                HStack{
                    Image("location_icon")
                        .opacity(selectedRadius == value ? 1 : 0.22)
                    
                    Text("Within \(value.formattedString(format: .int)) miles")
                        .textCustom(selectedRadius == value ? .coreSansC55Medium : .coreSansC45Regular, 16, Color.col_text_main)
                    
                    Spacer()
                    
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
                    .frame(width: 28, height: 28)
                    .opacity(selectedRadius == value ? 1 : 0)
                }
                .frame(height: 50)
                .background(Color.col_white)
                .onTapGesture {
                    selectedRadius = value
                }
                
                CustomDivider()
                    .opacity(value == radiusValues.last ? 0 : 1)
            }
            
            Spacer()
            
            MainButton(title: "Confirm") {
                mode.wrappedValue.dismiss()
            }
        }
        .padding(.horizontal, 24)
        .navBarSettings("Geolocation")
    }
}
