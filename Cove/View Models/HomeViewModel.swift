//
//  HomeViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/6/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth

class HomeViewModel: ObservableObject {
    @Published var products = [any Product]()
    @Published var brands = [Brand]()
    var fetchedProductIDs = [String]()

    let categories = ["Music", "Coffee", "Home", "Bevs", "Apparel"]
    let origins = ["Colombia", "Guatemala", "Ethiopia", "Costa Rica", "Kenya"]
    
    /// Fetches products from Firebase and populates the products array used in the HomeView
    func fetchProducts() async throws {
        // Check if products have already been fetched
        if !products.isEmpty {
            return
        }
        
        // Get a reference to Firestore
        print("Fetching products...")
        
        fetchedProductIDs = [String]()

        let db = Firestore.firestore()
        
        do {
            // Fetch 'product' documents from the 'products' collection
            var snapshot = try await db.collection("products").getDocuments()
            
            // Map fetched documents to the `products` array
            var products: [any Product] = snapshot.documents.compactMap { d in
                // Decode document's categoryID to determine what product type it is
                let categoryID = d["categoryID"] as? String
                do {
                    if categoryID == ProductTypes.coffee.rawValue {
                        // Decode as a CoffeeProduct
                        let coffeeProduct = try d.data(as: CoffeeProduct.self)
                        fetchedProductIDs.append(d.documentID)
                        return coffeeProduct
                    } else if categoryID == ProductTypes.music.rawValue {
                        // Decode as a MusicProduct
                        let musicProduct = try d.data(as: MusicProduct.self)
                        fetchedProductIDs.append(d.documentID)
                        return musicProduct
                    } else if categoryID == ProductTypes.apparel.rawValue {
                        // Decode as a ApparelProduct
                        let apparelProduct = try d.data(as: ApparelProduct.self)
                        fetchedProductIDs.append(d.documentID)
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
            snapshot = try await db.collection("users").document(user.uid).collection("favorites").whereField("productID", in: fetchedProductIDs).getDocuments()
            
            for document in snapshot.documents {
                do {
                    // Decode as a FavoriteProduct
                    let favoriteProduct = try document.data(as: FavoriteProduct.self)
                    // Get the index of the already-fetched product that matches the current favorite product
                    let indexOfFavorite = products.firstIndex { fetchedProduct in
                        fetchedProduct.id == favoriteProduct.productID
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
            
            // Ensure the products array wont change while being sent to the main thread by making it constant
            let sendableProducts = products
            await MainActor.run(body: {
                self.products = sendableProducts
            })
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
        let db = Firestore.firestore()
        
        do {
            // Fetch 'brand' documents from the 'brands' collection
            var snapshot = try await db.collection("brands").getDocuments()
            
            // Map fetched documents to the `brands` array
            let brands: [Brand] = snapshot.documents.compactMap { d in
                do {
                    return try d.data(as: Brand.self)
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
            
            await MainActor.run(body: {
                self.brands = brands
            })
        } catch {
            print(error)
            throw error
        }
    }
}


