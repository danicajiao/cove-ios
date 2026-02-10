//
//  LikeButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/9/22.
//

import SwiftUI

struct LikeButton : View {
    @State var enabled: Bool
    @State private var pressed = false
    @State private var scale = 1.0
    
    func haptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 26, height: 26)
                .foregroundStyle(Color.Colors.Fills.secondary)
            Image(systemName: enabled ? "heart.fill" : "heart")
                .font(.system(size: 14))
                .foregroundStyle(enabled ? .pink : Color.Colors.Strokes.primary)
        }
        .scaleEffect(scale)
        .onLongPressGesture(minimumDuration: 2.5, maximumDistance: .infinity, pressing: { pressing in
            self.pressed = pressing
            if pressing {
                haptic()
                withAnimation(.linear(duration: 0.1)) {
                    self.scale = 1.5
                }
            } else {
                haptic()
                withAnimation(.easeOut(duration: 0.3)) {
                    self.scale = 1.0
                }
                self.enabled.toggle()
            }
        }, perform: { })
    }
}

//struct StatefulPreviewWrapper<Value, Content: View>: View {
//    @State var value: Value
//    var content: (Binding<Value>) -> Content
//
//    var body: some View {
//        content($value)
//    }
//
//    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
//        self._value = State(wrappedValue: value)
//        self.content = content
//    }
//}
//
//struct LikeButton_Previews: PreviewProvider {
//    static var previews: some View {
//        StatefulPreviewWrapper(false) { LikeButton(enabled: $0) }
//        .previewLayout(.sizeThatFits)
//    }
//}
