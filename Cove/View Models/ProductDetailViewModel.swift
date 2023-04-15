//
//  ProductDetailViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/9/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class ProductDetailViewModel : ObservableObject {
    var product: (any Product)?
    @Published var productDetails: ProductDetails?
    @Published var detailSelection: DetailSelection
    @Published var similarProducts: [any Product]
    var fetchedProductIDs = [String]()
    
    enum DetailSelection {
        case description
        case about
        
        case specifications
        case origin
        case tracklist
    }
    
    init(product: (any Product)?) {
        self.product = product
        self.detailSelection = .description
        self.similarProducts = [any Product]()
    }
    
    func fetchProductDetails() async throws {
        // Check if product have already been fetched
        guard let product = self.product else {
            return
        }
        
        // Get a reference to Firestore
        print("Fetching product details...")
        let db = Firestore.firestore()
        
        do {
            // Fetch 'product detail' document from the 'product_details' collection
            let snapshot = try await db.collection("product_details").document(product.productDetailsID).getDocument()

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
    
    /// Fetches products from Firebase and populates the products array used in the HomeView
    func fetchSimilarProducts() async throws {
        // Check if products have already been fetched
        if !similarProducts.isEmpty {
            return
        }
        
        // Check if product have already been fetched
        guard let product = self.product else {
            return
        }
        
        // Get a reference to Firestore
        print("Fetching similar products...")
        let db = Firestore.firestore()
        
        do {
            // Fetch 'product' documents from the 'products' collection
            var snapshot = try await db.collection("products")
                .whereField("categoryID", isEqualTo: product.categoryID)
                .limit(to: 5)
                .getDocuments()
            
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
                self.similarProducts = sendableProducts
            })
        } catch {
            print(error)
            throw error
        }
    }
}
