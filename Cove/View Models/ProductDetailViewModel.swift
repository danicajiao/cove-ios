//
//  ProductDetailViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/9/23.
//

import FirebaseAuth
import FirebaseFirestore

class ProductDetailViewModel: ObservableObject {
    @Published var product: (any Product)?
    @Published var productDetails: ProductDetails?
    @Published var detailSelection: DetailSelection
    @Published var similarProducts: [any Product]
    var fetchedProductIds = [String]()

    enum DetailSelection {
        case description
        case about

        case specifications
        case origin
        case tracklist
    }

    init(productId: String) {
        product = nil
        detailSelection = .description
        similarProducts = [any Product]()

        Task {
            await fetchProduct(productId)
            if self.product != nil {
                do {
                    try await fetchProductDetails()
                    try await fetchSimilarProducts()
                } catch {
                    print("Error fetching product details or similar products: \(error)")
                }
            }
        }
    }

    func fetchProduct(_ id: String) async {
        print("Fetching product with id: \(id)")
        let firestore = Firestore.firestore()

        do {
            let snapshot = try await firestore.collection("products").document(id).getDocument()

            guard snapshot.exists else {
                print("Product with id \(id) does not exist")
                return
            }

            guard let categoryId = snapshot["categoryId"] as? String else {
                print("Product document missing categoryId field")
                return
            }

            if categoryId == ProductTypes.coffee.rawValue {
                let coffeeProduct = try snapshot.data(as: CoffeeProduct.self)
                await MainActor.run { self.product = coffeeProduct }
            } else if categoryId == ProductTypes.music.rawValue {
                let musicProduct = try snapshot.data(as: MusicProduct.self)
                await MainActor.run { self.product = musicProduct }
            } else if categoryId == ProductTypes.apparel.rawValue {
                let apparelProduct = try snapshot.data(as: ApparelProduct.self)
                await MainActor.run { self.product = apparelProduct }
            } else {
                print("Unknown product category: \(categoryId)")
            }

            await fetchFavoriteStatus(for: id)
        } catch {
            print("Error fetching product: \(error)")
        }
    }

    private func fetchFavoriteStatus(for productId: String) async {
        guard let user = Auth.auth().currentUser else { return }
        let firestore = Firestore.firestore()
        do {
            let snapshot = try await firestore.collection("users").document(user.uid).collection("favorites")
                .whereField("productId", isEqualTo: productId)
                .getDocuments()
            let isFavorite = !snapshot.documents.isEmpty
            await MainActor.run { self.product?.isFavorite = isFavorite }
        } catch {
            print("Error fetching favorite status: \(error)")
        }
    }

    func toggleFavorite() async {
        guard let productId = product?.id else { return }
        guard let user = Auth.auth().currentUser else { return }

        let isCurrentlyFavorited = product?.isFavorite == true
        let firestore = Firestore.firestore()
        let favoritesRef = firestore.collection("users").document(user.uid).collection("favorites")

        do {
            if isCurrentlyFavorited {
                let snapshot = try await favoritesRef.whereField("productId", isEqualTo: productId).getDocuments()
                for document in snapshot.documents {
                    try await document.reference.delete()
                }
            } else {
                try await favoritesRef.addDocument(from: FavoriteProduct(productId: productId))
            }
            await MainActor.run { self.product?.isFavorite = !isCurrentlyFavorited }
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }

    func fetchProductDetails() async throws {
        // Check if product have already been fetched
        guard let product else {
            return
        }

        // Get a reference to Firestore
        print("Fetching product details...")
        let firestore = Firestore.firestore()

        do {
            // Fetch 'product detail' document from the 'product_details' collection
            let snapshot = try await firestore.collection("product_details").document(product.productDetailsId).getDocument()

            if product is MusicProduct {
                let productDetails = try snapshot.data(as: MusicProductDetails.self)

                await MainActor.run(body: {
                    self.productDetails = productDetails
                })
            } else if product is CoffeeProduct {
                let productDetails = try snapshot.data(as: CoffeeProductDetails.self)

                await MainActor.run(body: {
                    self.productDetails = productDetails
                })
            } else if product is ApparelProduct {
                let productDetails = try snapshot.data(as: ApparelProductDetails.self)

                await MainActor.run(body: {
                    self.productDetails = productDetails
                })
            }
        } catch {
            print(error)
            throw error
        }
    }

    private func decodeProduct(from document: QueryDocumentSnapshot) -> (any Product)? {
        let categoryId = document["categoryId"] as? String
        do {
            if categoryId == ProductTypes.coffee.rawValue {
                return try document.data(as: CoffeeProduct.self)
            } else if categoryId == ProductTypes.music.rawValue {
                return try document.data(as: MusicProduct.self)
            } else if categoryId == ProductTypes.apparel.rawValue {
                return try document.data(as: ApparelProduct.self)
            }
        } catch {
            print(error)
        }
        return nil
    }

    private func applyFavorites(to products: inout [any Product], snapshot: QuerySnapshot) throws {
        for document in snapshot.documents {
            do {
                let favoriteProduct = try document.data(as: FavoriteProduct.self)
                guard let index = products.firstIndex(where: { $0.id == favoriteProduct.productId }) else {
                    print("Failed to get local index of favorite product")
                    return
                }
                products[index].isFavorite = true
            } catch {
                print(error)
                throw error
            }
        }
    }

    /// Fetches products from Firebase and populates the products array used in the HomeView
    func fetchSimilarProducts() async throws {
        if !similarProducts.isEmpty { return }
        guard let product else { return }

        print("Fetching similar products...")
        fetchedProductIds = [String]()
        let firestore = Firestore.firestore()

        do {
            var snapshot = try await firestore.collection("products")
                .whereField("categoryId", isEqualTo: product.categoryId)
                .limit(to: 5)
                .getDocuments()

            var products: [any Product] = snapshot.documents.compactMap { document in
                guard let decoded = decodeProduct(from: document) else { return nil }
                fetchedProductIds.append(document.documentID)
                return decoded
            }

            if products.isEmpty {
                print("No products returned from request")
                return
            }

            guard let user = Auth.auth().currentUser else {
                print("Failed to get signed in user to fetch favorites")
                return
            }

            snapshot = try await firestore.collection("users").document(user.uid).collection("favorites")
                .whereField("productId", in: fetchedProductIds)
                .getDocuments()

            try applyFavorites(to: &products, snapshot: snapshot)

            let sendableProducts = products
            await MainActor.run(body: { self.similarProducts = sendableProducts })
        } catch {
            print(error)
            throw error
        }
    }
}
