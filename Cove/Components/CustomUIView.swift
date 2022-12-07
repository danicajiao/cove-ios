//
//  CustomUIView.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/22/22.
//

import Foundation
import SwiftUI

struct UITextFieldViewRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UITextField {
        UITextField()
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
    }
    
}
