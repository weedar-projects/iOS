//
//  UIElements.swift
//  Weelar
//
//  Created by Zelenskyi Ivan on 12.08.2021.
//

import SwiftUI

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct CheckBox: View {
    @Binding var checked: Bool

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? ColorManager.Buttons.buttonActiveColor : Color.secondary)
            .onTapGesture {
                self.checked.toggle()
            }
    }
}
