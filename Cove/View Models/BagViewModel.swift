//
//  BagViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/24/23.
//

import FirebaseAuth
import FirebaseFirestore

class BagViewModel: ObservableObject {
    @Published var similarProducts = [any Product]()
    var tempCategories = [String]()
    var fetchedProductIds = [String]()

    /// Fetches similar products from Firebase and populates the similarProducts array used in the HomeView
    func fetchSimilarProducts(categories: [String]) async throws {
        if categories.isEmpty {
            await MainActor.run(body: {
                self.similarProducts = []
            })
            return
        }
        
        if self.tempCategories == categories {
            return
        }

        // Get a reference to Firestore
        print("Fetching similar products...")
        
        fetchedProductIds = [String]()
        
        let db = Firestore.firestore()

        do {
            // Fetch 'product' documents from the 'products' collection
            var snapshot = try await db.collection("products").whereField("categoryId", in: categories).getDocuments()

            // Map fetched documents to the `products` array
            var products: [any Product] = snapshot.documents.compactMap { d in
                // Decode document's categoryId to determine what product type it is
                let categoryId = d["categoryId"] as? String
                do {
                    if categoryId == ProductTypes.coffee.rawValue {
                        // Decode as a CoffeeProduct
                        let coffeeProduct = try d.data(as: CoffeeProduct.self)
                        fetchedProductIds.append(d.documentID)
                        return coffeeProduct
                    } else if categoryId == ProductTypes.music.rawValue {
                        // Decode as a MusicProduct
                        let musicProduct = try d.data(as: MusicProduct.self)
                        fetchedProductIds.append(d.documentID)
                        return musicProduct
                    } else if categoryId == ProductTypes.apparel.rawValue {
                        // Decode as a ApparelProduct
                        let apparelProduct = try d.data(as: ApparelProduct.self)
                        fetchedProductIds.append(d.documentID)
                        return apparelProduct
                    }
                } catch {
                    print(error)
                    return nil
                }
                return nil
            }

            // Check if no products were fetched from last request
            if products.isEmpty {
                print("No products returned from request")
                return
            }

            // Check if a user is logged in
            guard let user = Auth.auth().currentUser else {
                print("Failed to get signed in user to fetch favorites")
                return
            }

            // Fetch 'favorite' documents from the logged in user's 'favorites' collection that were already fetched in the last request
            snapshot = try await db.collection("users").document(user.uid).collection("favorites").whereField("productId", in: fetchedProductIds).getDocuments()

            for document in snapshot.documents {
                do {
                    // Decode as a FavoriteProduct
                    let favoriteProduct = try document.data(as: FavoriteProduct.self)
                    // Get the index of the already-fetched product that matches the current favorite product
                    let indexOfFavorite = products.firstIndex { fetchedProduct in
                        fetchedProduct.id == favoriteProduct.productId
                    }
                    // If the index was not found, return
                    guard let i = indexOfFavorite else {
                        print("Failed to get local index of favorite product")
                        return
                    }
                    products[i].isFavorite = true
                } catch {
                    print(error)
                    throw error
                }
            }
            
            self.tempCategories = categories

            // Ensure the products array wont change while being sent to the main thread by making it constant
            let sendableProducts = products
            await MainActor.run(body: {
                self.similarProducts = sendableProducts
            })
        } catch {
            print(error)
            throw error
        }
    }
}
