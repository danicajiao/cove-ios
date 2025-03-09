//
//  EmailField.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/7/25.
//

import SwiftUI

struct PasswordField: View {
    @Binding var text: String
    @State private var isSecured: Bool = true
    
    @FocusState.Binding var focus: Field?

    var body: some View {
        VStack(spacing: 5) {
            Text("Password")
                .font(.custom("Lato-Bold", size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
                .foregroundStyle(.black.opacity(0.5))
            HStack(spacing: 10) {
//                if isSecured {
//                    SecureField("Password", text: $text)
//                        .font(.custom("Lato-Regular", size: 14))
//                        .focused($focus, equals: Field.password)
//                } else {
//                    TextField("Password", text: $text)
//                        .font(.custom("Lato-Regular", size: 14))
//                        .focused($focus, equals: Field.password)
//                }
                
                Button {
                    isSecured.toggle()
                } label: {
                    Image(systemName: self.isSecured ? "eye.slash" : "eye")
                        .accentColor(.black.opacity(0.5))
                }
            }
            .font(.custom("Lato-Regular", size: 14))
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.black, lineWidth: 1)
            )
            .onTapGesture {
                if focus != .password {
                    focus = .password
                }
            }
            
            Button {
                
            } label: {
                Text("Forgot password?")
                    .font(.custom("Lato-Regular", size: 14))
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.black.opacity(0.5))
            }
        }
    }
}

#Preview {
    @Previewable @State var password: String = ""
    @Previewable @FocusState var focusedField: Field?
    
    PasswordField(text: $password, focus: $focusedField)
        .padding()
        .background(Color.background)
}

