//
//  TestView.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/25/25.
//

import SwiftUI
import UIKit

class TestViewController: UIViewController {
    var textField = UITextField()
    weak var delegate: UITextFieldDelegate?
    
    // Gets called during super.init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad HIT")
                
        textField.delegate = delegate
        textField.backgroundColor = .yellow
        textField.translatesAutoresizingMaskIntoConstraints = false
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        print("Intrinsic textfield size: \(textField.intrinsicContentSize)")

        self.view.addSubview(textField)
        
        print("viewDidLoad -> textField.frame.height \(textField.frame.height)")
        
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalTo: self.view.widthAnchor),
//            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: textField.frame.height), // Minimum height of 64 points
//            textField.heightAnchor.constraint(equalTo: self.view.heightAnchor)
//            self.view.widthAnchor.constraint(equalToConstant: 64),
            self.view.heightAnchor.constraint(greaterThanOrEqualToConstant: textField.intrinsicContentSize.height)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("viewDidLayoutSubviews HIT")
        print("viewDidLayoutSubviews -> textField.frame.height \(textField.frame.height)")
        
//        NSLayoutConstraint.activate([
//            self.view.heightAnchor.constraint(greaterThanOrEqualToConstant: textField.frame.height)
//        ])
//        
//        print(self.view.constraints)

    }
}

struct TestViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = TestViewController

    @Binding var text: String
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TestViewRepresentable
        
        init(parent: TestViewRepresentable) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> TestViewController {
        print("makeUIViewController HIT")
        let viewController = TestViewController()
        viewController.delegate = context.coordinator // Setting the coordinator as the delegate
        viewController.textField.text = text
        print("makeUIViewController -> textField.frame.height \(viewController.textField.frame.height)")
        return viewController
    }

    func updateUIViewController(_ uiViewController: TestViewController, context: Context) {
        // Update the view controller if needed
        print("updateUIViewController HIT")
        uiViewController.textField.text = text
        print("updateUIViewController -> textField.frame.height \(uiViewController.textField.frame.height)")
    }
}

#Preview {
    @Previewable @State var password: String = "hello"
    @Previewable @State var rightAreaToggle: Bool = true
    @Previewable @State var bottomAreaToggle: Bool = true
    
    VStack {
        Text(password)
        HStack {
            TestViewRepresentable(text: $password)
                .border(.green)
//                .frame(width: 100, height: 10)
                .background(Color.blue)
            if rightAreaToggle {
                Text("Right of the TextField")
                    .border(.purple)
            }
        }
        if bottomAreaToggle {
            HStack {
                Rectangle()
                    .fill(Color.green)
                    .frame(maxWidth: .infinity, maxHeight: 100)
                Rectangle()
                    .fill(Color.cyan)
                    .frame(width: 100, height: 100)
            }
        }
        HStack{
            Toggle("right", isOn: $rightAreaToggle)
            Toggle("bottom", isOn: $bottomAreaToggle)
        }
        TextField("Placeholder", text: $password)
//            .frame(width: 100, height: 100)
            .background(Color.yellow)
    }
    .border(.red)
    .padding()
}
