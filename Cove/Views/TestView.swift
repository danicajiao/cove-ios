//
//  TestView.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/25/25.
//

import SwiftUI
import UIKit

struct SecureTextFieldViewRepresentable: UIViewRepresentable {
    var titleKey: String
    var font: UIFont?
    @Binding var text: String
    @Binding var isSecured: Bool
    @FocusState.Binding var focus: Field?
    var fieldType: Field?

    class Coordinator: NSObject, UITextFieldDelegate {
        var titleKey: String
        @Binding var text: String
        @Binding var isSecured: Bool

        init(titleKey: String, text: Binding<String>, isSecured: Binding<Bool>) {
            self.titleKey = titleKey
            self._text = text
            self._isSecured = isSecured
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(titleKey: titleKey, text: $text, isSecured: $isSecured)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.isSecureTextEntry = isSecured
        textField.delegate = context.coordinator
        
        // Styling options
        textField.font = font
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.textColor = .black
//        textField.backgroundColor = .white
        textField.placeholder = self.titleKey
//        textField.setValue(UIColor.lightGray, forKeyPath: "placeholderLabel.textColor")
        
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = isSecured
        if focus == fieldType {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    
    }
}

// Any modifiers to adjust your text field – copy self, adjust, then return.
extension SecureTextFieldViewRepresentable {
    func font(_ font: UIFont?) -> SecureTextFieldViewRepresentable {
        var view = self
        view.font = font
        return view
    }
    
    func focused(_ binding: FocusState<Field?>.Binding, equals: Field) -> SecureTextFieldViewRepresentable {
        var view = self
        view._focus = binding
        view.fieldType = equals
        return view
    }
}

struct SecureTextField: View {
    var titleKey: String
    @Binding var text: String
    @Binding var isSecured: Bool
    @FocusState.Binding var focus: Field?
    
    var body: some View {
        VStack(spacing: 5) {
            Text("Email")
                .font(.custom("Lato-Bold", size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
            //                .padding(.horizontal)
                .foregroundStyle(.black.opacity(0.5))
            SecureTextFieldViewRepresentable(titleKey: titleKey, text: $text, isSecured: $isSecured)
                .font(UIFont(name: "Lato-Regular", size: 14))
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.black, lineWidth: 1)
                )
                .focused($focus, equals: Field.password)
            Button {
                isSecured.toggle()
            } label: {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.black.opacity(0.5))
            }
        }
    }
}

#Preview {
    @Previewable @State var password: String = ""
    @Previewable @State var isSecured: Bool = false
    @Previewable @FocusState var focusedField: Field?

    VStack {
        SecureTextField(titleKey: "Password", text: $password, isSecured: $isSecured)
        
        Toggle(isOn: $isSecured) {
            Text("isSecured")
        }
    }
    .background(Color.background)
    .padding(20)
    
}
