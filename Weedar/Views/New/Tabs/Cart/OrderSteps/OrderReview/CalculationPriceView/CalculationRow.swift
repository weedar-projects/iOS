//
//  CalculationRow.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 14.03.2022.
//

import SwiftUI

struct CalculationRow: View{
    @State var title = ""
    @Binding var value: Double
    @State var lightText = false
    
    @State var isDiscount = false
    var body: some View{
        HStack{
            Text(title)
                .textCustom(.coreSansC45Regular, 16, lightText ? Color.col_text_white : Color.col_text_main.opacity(0.6))
            
            Spacer()
            
            Text("\(isDiscount ? "-" : "")$\(value.formattedString(format: .percent))")
                .textCustom(.coreSansC45Regular, 16, lightText ? Color.col_text_white : Color.col_text_main.opacity(0.6))
        }
    }
}
