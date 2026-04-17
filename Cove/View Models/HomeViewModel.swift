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
    var fetchedProductIds = [String]()

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

    private func applyFavorites(to products: inout [any Product], snapshot: QuerySnapshot) {
        for document in snapshot.documents {
            do {
                let favoriteProduct = try document.data(as: FavoriteProduct.self)
                guard let index = products.firstIndex(where: { $0.id == favoriteProduct.productId }) else {
                    print("Failed to get local index of favorite product: \(favoriteProduct.productId)")
                    continue
                }
                products[index].isFavorite = true
            } catch {
                print("Failed to decode favorite: \(error)")
            }
        }
    }

    /// Fetches products from Firebase and populates the products array used in the HomeView
    func fetchProducts() async throws {
        if !products.isEmpty { return }

        print("Fetching products...")
        fetchedProductIds = [String]()
        let firestore = Firestore.firestore()

        do {
            var snapshot = try await firestore.collection("products").getDocuments()

            var products: [any Product] = snapshot.documents.compactMap { document in
                guard let product = decodeProduct(from: document) else { return nil }
                fetchedProductIds.append(document.documentID)
                return product
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

            applyFavorites(to: &products, snapshot: snapshot)

            self.products = products
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
