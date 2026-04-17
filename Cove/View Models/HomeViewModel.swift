//
//  HomeViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/6/22.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
class HomeViewModel: ObservableObject {
    @Published var products = [any Product]()
    @Published var brands = [Brand]()
    @Published var hasMoreProducts = true
    @Published var isLoadingMore = false
    var fetchedProductIds = [String]()

    private let pageSize = 20
    private var lastDocument: DocumentSnapshot?

    let categories = ["Music", "Coffee", "Home", "Bevs", "Apparel"]
    let origins = ["Colombia", "Guatemala", "Ethiopia", "Costa Rica", "Kenya"]

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

    /// Fetches the first page of products from Firebase. No-ops if products are already loaded.
    func fetchProducts() async throws {
        guard products.isEmpty else { return }

        fetchedProductIds = []
        lastDocument = nil
        hasMoreProducts = true

        try await loadPage()
    }

    /// Fetches the next page of products and appends them to the products array.
    func fetchMoreProducts() async throws {
        guard hasMoreProducts, !isLoadingMore else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        try await loadPage()
    }

    private func loadPage() async throws {
        print("Fetching products (page \(products.count / pageSize + 1))...")
        let firestore = Firestore.firestore()

        do {
            var query = firestore.collection("products")
                .order(by: "createdAt", descending: true)
                .limit(to: pageSize)

            if let lastDocument {
                query = query.start(afterDocument: lastDocument)
            }

            let snapshot = try await query.getDocuments()

            var newProducts: [any Product] = snapshot.documents.compactMap { document in
                guard let product = decodeProduct(from: document) else { return nil }
                fetchedProductIds.append(document.documentID)
                return product
            }

            if newProducts.isEmpty {
                hasMoreProducts = false
                return
            }

            hasMoreProducts = snapshot.documents.count == pageSize
            lastDocument = snapshot.documents.last

            guard let user = Auth.auth().currentUser else {
                print("Failed to get signed in user to fetch favorites")
                self.products.append(contentsOf: newProducts)
                return
            }

            let newIds = newProducts.compactMap { $0.id }
            let favSnapshot = try await firestore.collection("users").document(user.uid).collection("favorites")
                .whereField("productId", in: newIds)
                .getDocuments()

            try applyFavorites(to: &newProducts, snapshot: favSnapshot)

            self.products.append(contentsOf: newProducts)
        } catch {
            print(error)
            throw error
        }
    }

    func fetchBrands() async throws {
        // Check if products have already been fetched
        if !brands.isEmpty {
            return
        }

        // Get a reference to Firestore
        print("Fetching brands...")
        let firestore = Firestore.firestore()

        do {
            // Fetch 'brand' documents from the 'brands' collection
            let snapshot = try await firestore.collection("brands").getDocuments()

            // Map fetched documents to the `brands` array
            let brands: [Brand] = snapshot.documents.compactMap { document in
                do {
                    return try document.data(as: Brand.self)
                } catch {
                    print(error)
                    return nil
                }
            }

            // Check if no brands were fetched from last request
            if brands.isEmpty {
                print("No brands returned from request")
                return
            }

            self.brands = brands
        } catch {
            print(error)
            throw error
        }
    }
}
