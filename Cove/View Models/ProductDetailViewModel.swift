//
//  ProductDetailViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/9/23.
//

import FirebaseFirestore
import FirebaseAuth

class ProductDetailViewModel : ObservableObject {
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
        self.product = nil
        self.detailSelection = .description
        self.similarProducts = [any Product]()
        
        Task {
            await fetchProduct(productId)
            if let product = self.product {
                try? await fetchProductDetails()
                try? await fetchSimilarProducts()
            }
        }
    }
    
    func fetchProduct(_ id: String) async {
        print("Fetching product with id: \(id)")
        let db = Firestore.firestore()
        
        do {
            // Fetch the product document from Firestore
            let snapshot = try await db.collection("products").document(id).getDocument()
            
            // Get the categoryId to determine the product type
            let categoryId = snapshot["categoryId"] as? String
            
            // Decode based on product type
            if categoryId == ProductTypes.coffee.rawValue {
                let coffeeProduct = try snapshot.data(as: CoffeeProduct.self)
                await MainActor.run {
                    self.product = coffeeProduct
                }
            } else if categoryId == ProductTypes.music.rawValue {
                let musicProduct = try snapshot.data(as: MusicProduct.self)
                await MainActor.run {
                    self.product = musicProduct
                }
            } else if categoryId == ProductTypes.apparel.rawValue {
                let apparelProduct = try snapshot.data(as: ApparelProduct.self)
                await MainActor.run {
                    self.product = apparelProduct
                }
            }
        } catch {
            print("Error fetching product: \(error)")
        }
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
            let snapshot = try await db.collection("product_details").document(product.productDetailsId).getDocument()

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
        
        fetchedProductIds = [String]()

        let db = Firestore.firestore()
        
        do {
            // Fetch 'product' documents from the 'products' collection
            var snapshot = try await db.collection("products")
                .whereField("categoryId", isEqualTo: product.categoryId)
                .limit(to: 5)
                .getDocuments()
            
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
