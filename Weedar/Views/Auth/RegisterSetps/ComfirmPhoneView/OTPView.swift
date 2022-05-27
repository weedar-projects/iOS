//
//  OTPView.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 08.10.2021.
//

import SwiftUI

struct OTPView: View {
  // MARK: - Properties
  @StateObject var viewModel: ComfirmPhoneVM
  
  let textBoxWidth: CGFloat = (UIScreen.main.bounds.width - (12 * 5)) / 6
  let textBoxHeight: CGFloat = 48
  let spaceBetweenBoxes: CGFloat = 12
  let paddingOfBox: CGFloat = 1
  
  
  // MARK: - View
  var body: some View {
    VStack {
      ZStack {
        HStack {
          otpText(viewModel.otp1)
          otpText(viewModel.otp2)
          otpText(viewModel.otp3)
          otpText(viewModel.otp4)
          otpText(viewModel.otp5)
          otpText(viewModel.otp6)
        } // HStack
        
        TextField("", text: $viewModel.otpField)
          .textContentType(.oneTimeCode)
          .foregroundColor(.clear)
          .accentColor(.clear)
          .background(Color.clear)
          .keyboardType(.numberPad)
      } // ZStack
    } // VStack
    .frame(width: UIScreen.main.bounds.width, height: 48)
  } // body
  
  
  // MARK: - Custom functions
  private func otpText(_ text: String) -> some View {
    Text(text)
      .frame(width: textBoxWidth / 3, height: textBoxHeight)
      .modifier(
        TextFieldModifier(cornerRadius: 12,
                          borderWidth: 2,
                          height: 48,
                          borderColor: .constant(viewModel.isErrorShow ? Color.col_red_second : (text == "" ? Color.col_borders : Color.col_green_second)),
                          font: .coreSansC45Regular,
                          size: 16,
                          textAlignment: .center)
      )
      .padding(paddingOfBox)
  }
}
