//
//  CustomTextField.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/7/25.
//

import SwiftUI
import UIKit

enum Field: Hashable {
    case email
    case password
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var focusable: Binding<[Bool]>?
    @State var isSecureTextEntry: Bool
    @State var isHidden: Bool?
    
    var returnKeyType: UIReturnKeyType
    var autocapitalizationType: UITextAutocapitalizationType
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var uiFont: UIFont?
    var label: String? = nil
    
    var tag: Int? = nil
    var inputAccessoryView: UIToolbar? = nil
    
    var onCommit: (() -> Void)? = nil
    
    init(placeholder: String, text: Binding<String>, focusable: Binding<[Bool]>? = nil, isSecureTextEntry: Bool = false, returnKeyType: UIReturnKeyType, autocapitalizationType: UITextAutocapitalizationType = .none, keyboardType: UIKeyboardType = .default, textContentType: UITextContentType? = nil, uiFont: UIFont? = UIFont(name: "Lato-Regular", size: 14), label: String? = nil, tag: Int? = nil, inputAccessoryView: UIToolbar? = nil, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.focusable = focusable
        self.isSecureTextEntry = isSecureTextEntry
        self.isHidden = isSecureTextEntry
        self.returnKeyType = returnKeyType
        self.autocapitalizationType = autocapitalizationType
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.uiFont = uiFont
        self.label = label
        self.tag = tag
        self.inputAccessoryView = inputAccessoryView
        self.onCommit = onCommit
    }
    
    var body: some View {
        VStack(spacing: 5) {
            if label != nil {
                Text(label ?? "")
                    .font(.custom("Lato-Bold", size: 12))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .foregroundStyle(.black.opacity(0.5))
            }
            HStack {
                UITextFieldRepresentable(
                    placeholder: placeholder,
                    text: $text,
                    focusable: focusable,
                    isHidden: $isHidden,
                    returnKeyType: returnKeyType,
                    autocapitalizationType: autocapitalizationType,
                    keyboardType: keyboardType,
                    textContentType: textContentType,
                    uiFont: uiFont,
                    tag: tag
                )
                if isSecureTextEntry {
                    Button {
                        isHidden?.toggle()
                    } label: {
                        Image(systemName: (isHidden ?? true) ? "eye.slash" : "eye")
                            .accentColor(.black.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 10)
//            .frame(maxWidth: .infinity, maxHeight: 50)
            .frame(height: 50)
            .background(Color.white)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.black, lineWidth: 1)
            }
        }
    }
}

struct UITextFieldRepresentable: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    
    var focusable: Binding<[Bool]>? = nil
//    var isSecureTextEntry: Binding<Bool>? = nil
    @Binding var isHidden: Bool?
    
    var returnKeyType: UIReturnKeyType = .default
    var autocapitalizationType: UITextAutocapitalizationType = .none
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var uiFont: UIFont? = nil
    
    var tag: Int? = nil
    var inputAccessoryView: UIToolbar? = nil
    
    var onCommit: (() -> Void)? = nil
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        
        textField.returnKeyType = returnKeyType
        textField.autocapitalizationType = autocapitalizationType
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isHidden ?? false
        textField.textContentType = textContentType
        textField.textAlignment = .left
        textField.font = uiFont
//        textField.layer.borderColor = UIColor.red.cgColor
//        textField.layer.borderWidth = 1
        
        if let tag = tag {
            textField.tag = tag
        }
        
        textField.inputAccessoryView = inputAccessoryView
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = isHidden ?? false
        
        if let focusable = focusable?.wrappedValue {
            var resignResponder = true
            
            for (index, focused) in focusable.enumerated() {
                if uiView.tag == index && focused {
                    uiView.becomeFirstResponder()
                    resignResponder = false
                    break
                }
            }
            
            if resignResponder {
                uiView.resignFirstResponder()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        let parent: UITextFieldRepresentable
        
        init(_ parent: UITextFieldRepresentable) {
            self.parent = parent
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            print("textFieldDidBeginEditing HIT")
            guard var focusable = parent.focusable?.wrappedValue else { return }
            
            for i in 0...(focusable.count - 1) {
                focusable[i] = (textField.tag == i)
            }
            
            parent.focusable?.wrappedValue = focusable
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard var focusable = parent.focusable?.wrappedValue else {
                textField.resignFirstResponder()
                return true
            }
            
            for i in 0...(focusable.count - 1) {
                focusable[i] = (textField.tag + 1 == i)
            }
            
            parent.focusable?.wrappedValue = focusable
            
            if textField.tag == focusable.count - 1 {
                textField.resignFirstResponder()
            }
            
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onCommit?()
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}

#Preview {
    @Previewable @State var email: String = ""
    @Previewable @State var password: String = ""
    @Previewable @State var fieldFocus = [false, false]
    
    VStack {
        Text("email: \(email)")
        Text("password: \(password)")
        CustomTextField(
            placeholder: "email@provider.com",
            text: $email,
            focusable: $fieldFocus,
            returnKeyType: .next,
            label: "Email",
            tag: 0
        )
        CustomTextField(
            placeholder: "Password",
            text: $password,
            focusable: $fieldFocus,
            isSecureTextEntry: true,
            returnKeyType: .done,
            label: "Password",
            tag: 1
        )
    }
    .padding()
}
