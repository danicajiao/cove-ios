//
//  TestView.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/25/25.
//

import SwiftUI
import UIKit
import CHTCollectionViewWaterfallLayout

// MARK: - SwiftUI Wrapper
struct WaterfallCollectionView: UIViewControllerRepresentable {
    // Example data for demonstration
    let items: [String] = Array(1...50).map { "Item \($0)" }
    
    func makeUIViewController(context: Context) -> UICollectionViewController {
        // Initialize the waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 2 // Number of columns
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Create the UICollectionViewController
        let collectionViewController = UICollectionViewController(collectionViewLayout: layout)
        collectionViewController.collectionView.dataSource = context.coordinator
        collectionViewController.collectionView.delegate = context.coordinator
        collectionViewController.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        return collectionViewController
    }
    
    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
        // Handle updates if necessary
        uiViewController.collectionView.reloadData()
    }
    
    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout {
        var parent: WaterfallCollectionView
        
        init(_ parent: WaterfallCollectionView) {
            self.parent = parent
        }
        
        // MARK: - UICollectionViewDataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.items.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            cell.contentView.backgroundColor = .blue
            
            // Add a label to display the item (for demonstration purposes)
            if cell.contentView.subviews.isEmpty {
                let label = UILabel(frame: cell.contentView.bounds)
                label.textAlignment = .center
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
                label.tag = 100 // Tag for reuse
                cell.contentView.addSubview(label)
            }
            
            if let label = cell.contentView.viewWithTag(100) as? UILabel {
                label.text = parent.items[indexPath.item]
            }
            
            return cell
        }
        
        // MARK: - CHTCollectionViewDelegateWaterfallLayout
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // Return a size with a random height for demonstration
            let width = (collectionView.bounds.width - 30) / 2 // Adjust for column spacing and insets
            let height = CGFloat.random(in: 100...200)
            return CGSize(width: width, height: height)
        }
    }
}

// MARK: - SwiftUI Preview
struct TestView: View {
    var body: some View {
        WaterfallCollectionView()
            .ignoresSafeArea()
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
