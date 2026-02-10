//
//  EmailField.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/7/25.
//

import SwiftUI

struct EmailField: View {
    @Binding var text: String
    @FocusState.Binding var focus: Field?
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Email")
                .font(.custom("Lato-Bold", size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.black.opacity(0.5))
            TextField(String("email@example.com"), text: $text)
                .font(.custom("Lato-Regular", size: 14))
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.black, lineWidth: 1)
                )
                .focused($focus, equals: Field.email)
                .onTapGesture {
                    focus = Field.email
                }
        }
    }
}

#Preview {
    @Previewable @State var email: String = ""
    @Previewable @FocusState var focusedField: Field?

    EmailField(text: $email, focus: $focusedField)
        .padding()
        .background(Color(.Colors.Backgrounds.secondary))
        .onAppear {
            focusedField = Field.email
        }
}
