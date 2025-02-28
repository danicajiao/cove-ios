//
//  SecondaryButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/27/25.
//

import SwiftUI

struct SecondaryButton: PrimitiveButtonStyle {
    @State private var isPressed = false
    let width: CGFloat?
    let height: CGFloat?

    init(width: CGFloat? = .infinity, height: CGFloat? = 55) {
        self.width = width
        self.height = height
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Poppins-SemiBold", size: 14))
            .padding()
            .foregroundStyle(.white)
            .frame(maxWidth: self.width, maxHeight: self.height)
            .background {
                Capsule()
                    .fill(.black)
            }
            .contentShape(.capsule)
            // animation defaults
            .opacity(isPressed ? 0.2 : 1)
            .animation(.default, value: isPressed)
            .gesture(DragGesture(minimumDistance: 0).onChanged { _ in
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) {
                    isPressed = true
                }
            }.onEnded({ _ in
                isPressed = false
                configuration.trigger()
            }))
    }
}

struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Press Me") {
            print("Button pressed!")
        }
        .buttonStyle(SecondaryButton())
        .padding()
    }
}
