//
//  PrimaryButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/14/22.
//

import SwiftUI

struct PrimaryButton: ButtonStyle {
    let height: CGFloat?
    
    init(height: CGFloat? = 55) {
        self.height = height
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Poppins-SemiBold", size: 14))
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: self.height)
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
