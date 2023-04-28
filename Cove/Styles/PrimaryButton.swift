//
//  PrimaryButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/14/22.
//

import SwiftUI

struct PrimaryButton: ButtonStyle {
    let width: CGFloat?
    let height: CGFloat?

    init(width: CGFloat? = nil, height: CGFloat? = 55) {
        self.width = width
        self.height = height
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Poppins-SemiBold", size: 14))
//            .padding()
//            .border(Color.pink)
            .frame(maxWidth: self.width)
            .frame(maxHeight: self.height)
//            .border(Color.pink)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.black)
            }
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.2 : 1)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Press Me") {
            print("Button pressed!")
        }
        .buttonStyle(PrimaryButton())
    }
}
