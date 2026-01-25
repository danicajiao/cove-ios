//
//  WaterfallCollection.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/22/25.
//

import SwiftUI
import UIKit
import CHTCollectionViewWaterfallLayout
import FirebaseFirestore

// MARK: - SwiftUI Wrapper
struct WaterfallCollection: UIViewControllerRepresentable {
    let products: [any Product] // Accept products as input
    
    func makeUIViewController(context: Context) -> UICollectionViewController {
        // Initialize the waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 2 // Number of columns
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Create the UICollectionViewController
        let collectionViewController = UICollectionViewController(collectionViewLayout: layout)
        collectionViewController.collectionView.dataSource = context.coordinator
        collectionViewController.collectionView.delegate = context.coordinator
        collectionViewController.collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: "ProductCell")

        // Set the background color of the collection view to clear
        collectionViewController.collectionView.backgroundColor = .clear
        
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
        var parent: WaterfallCollection
        
        init(_ parent: WaterfallCollection) {
            self.parent = parent
        }
        
        // MARK: - UICollectionViewDataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.products.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCollectionViewCell
            let product = parent.products[indexPath.item]
            cell.configure(with: product) // Configure cell with product data
            return cell
        }
        
        // MARK: - CHTCollectionViewDelegateWaterfallLayout
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (collectionView.bounds.width - 30) / 2 // Adjust for column spacing and insets
//            let product = parent.products[indexPath.item]
//            
//            // Calculate the height based on the ProductCardView content
//            let height = calculateProductCardViewHeight(for: product, width: width)

            // Set a random height between 150 and 300
            let randomHeight = CGFloat.random(in: 150...300)
            
            return CGSize(width: width, height: randomHeight)
        }
    }
}

//extension UIView {
//    func sizeThatFits(_ targetSize: CGSize) -> CGSize {
//        return systemLayoutSizeFitting(
//            targetSize,
//            withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel
//        )
//    }
//}
//
//func calculateProductCardViewHeight(for product: any Product, width: CGFloat) -> CGFloat {
//    let hostingController = UIHostingController(rootView: ProductCardView(product: product))
//    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//    let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
//    return hostingController.view.sizeThatFits(targetSize).height
//}

// Custom UICollectionViewCell to display ProductCardView
// class ProductCollectionViewCell: UICollectionViewCell {
//     private var hostingController: UIHostingController<ProductCardView>?

//     override init(frame: CGRect) {
//         super.init(frame: frame)
//         // Initialize with a placeholder product
//         let placeholderProduct = ExampleProduct.placeholder // Replace with your concrete placeholder
//         hostingController = UIHostingController(rootView: ProductCardView(product: placeholderProduct))
//         hostingController?.view.translatesAutoresizingMaskIntoConstraints = false
//         if let hostingView = hostingController?.view {
//             contentView.addSubview(hostingView)
//             NSLayoutConstraint.activate([
//                 hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
//                 hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//                 hostingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//                 hostingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//             ])
//         }
//     }
    
//     required init?(coder: NSCoder) {
//         fatalError("init(coder:) has not been implemented")
//     }
    
//     func configure(with product: any Product) {
//         hostingController?.rootView = ProductCardView(product: product)
//     }
// }

class ProductCollectionViewCell: UICollectionViewCell {
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // Maintain aspect ratio
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set the background color of the contentView
        contentView.backgroundColor = UIColor.systemGray6 // Example color

        // Add subviews
        contentView.addSubview(productImageView)
//        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // ImageView at the top
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            productImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75), // Aspect ratio 4:3 (adjust as needed)
            
            // Name label below the image
//            nameLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
//            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
//            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Price label below the name
            priceLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with product: any Product) {
        // Set the image (you'll need to load it asynchronously if it's from a URL)
        if let imageURL = URL(string: product.defaultImageURL) {
            loadImage(from: imageURL) { [weak self] image in
                self?.productImageView.image = image
            }
        } else {
            productImageView.image = nil // Placeholder or empty state
        }
        
        // Set the name and price
        priceLabel.text = "$\(product.defaultPrice)"
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Example of loading an image asynchronously
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

// MARK: - SwiftUI Preview
struct ContentView: View {
    let product1 = ApparelProduct(
        id: "1aaaa",
        createdAt: Timestamp.init(),
        categoryID: "apparel category id",
        defaultPrice: 23,
        defaultImageURL: "gs://cove-6a685.appspot.com/product-images/1h6szGnA2L14XROhtIZx/pant.jpg",
        info: ApparelProduct.ApparelInfo(brand: "Some apparel brand", name: "Some apparel", colors: []),
        isFavorite: true,
        productDetailsID: "apparel details id"
    )
    
    let product2 = CoffeeProduct(
        id: "2aaaa",
        createdAt: Timestamp.init(),
        categoryID: "coffee category id",
        defaultPrice: 18,
        defaultImageURL: "gs://cove-6a685.appspot.com/product-images/YwZotBIfctX8wPNOMDWq/RTL-1015_2.jpeg",
        info: CoffeeProduct.CoffeeInfo(name: "Some coffee name", roastery: "Some roastery"),
        isFavorite: true,
        productDetailsID: "coffee details id"
    )
    
    var body: some View {
        WaterfallCollection(products: [product1, product2]) // Example usage
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
