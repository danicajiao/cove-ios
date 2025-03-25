//
//  ProductDetailView.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/8/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ProductDetailView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject var bag: Bag
    @StateObject var viewModel: ProductDetailViewModel
    
    var product: (any Product)?
    var headerStr: String = "Header"
    var bodyStr: String = "Body"
    var price: Float = 9
    
    @State var count: Int = 1
//    @State var detailSelection: ProductDetailViewModel.DetailSelection
    
    @State private var index = 0
    @State var viewPagerSize: CGSize = .zero
    
    init(product: any Product) {
        if let coffeeProduct = product as? CoffeeProduct {
            // Product is a CoffeeProduct
            self.product = coffeeProduct
            self._viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: coffeeProduct))

            self.headerStr = coffeeProduct.info.roastery
            self.bodyStr = coffeeProduct.info.name
            self.price = coffeeProduct.defaultPrice
        } else if let musicProduct = product as? MusicProduct {
            // Product is a MusicProduct
            self.product = musicProduct
            self._viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: musicProduct))

            self.headerStr = musicProduct.info.artist
            self.bodyStr = musicProduct.info.album
            self.price = musicProduct.defaultPrice
        } else if let apparelProduct = product as? ApparelProduct {
            // Product is a ApparelProduct
            self.product = apparelProduct
            self._viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: apparelProduct))

            self.headerStr = apparelProduct.info.brand
            self.bodyStr = apparelProduct.info.name
            self.price = apparelProduct.defaultPrice
        } else {
            self.product = nil
            self._viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: nil))
        }
    }
    
    var rows: [GridItem] = [
        GridItem(.adaptive(minimum: .infinity, maximum: .infinity), spacing: 20)
    ]
    
    func getSafeAreaTop() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        return (keyWindow?.safeAreaInsets.top)!
    }
    
    /// A preference key to store a view's rect
    public struct ViewSizeKey: PreferenceKey {
        public typealias Value = CGSize
        public static var defaultValue = CGSize.zero
        public static func reduce(value: inout Value, nextValue: () -> Value) {
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let product = self.product {
                    AsyncImage(url: URL(string: product.defaultImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                            .padding([.leading, .trailing], getSafeAreaTop())
                            .padding(.bottom, 20)
                            .background {
                                AsyncImage(url: URL(string: product.defaultImageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(-getSafeAreaTop())
                                        .blur(radius: 200)
                                } placeholder: { }
                            }
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 300)
                }

                Group {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text(headerStr)
                                .font(Font.custom("Poppins-Regular", size: 22))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack {
                                Text("$\(Int(self.price))")
                                    .font(Font.custom("Poppins-SemiBold", size: 22))
                                    .foregroundColor(.accent)

                                Spacer()

                                Button {
                                    if count > 1 {
                                        count = count - 1
                                    }
                                } label: {
                                    Image(systemName: "minus.square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                .foregroundColor(.accent)
                                .disabled(count == 1 ? true : false)

                                Text(String(count))
                                    .font(Font.custom("Poppins-Regular", size: 14))
                                    .frame(width: 30, height: 20)

                                Button {
                                    if count < 15 {
                                        count = count + 1
                                    }
                                } label: {
                                    Image(systemName: "plus.square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                .foregroundColor(.accent)
                                .disabled(count == 15 ? true : false)
                            }
                        }


                        NavigationLink(destination: Text("Item Reviews!")) {
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        RatingView(rating: 4)
                                        Text("4.3")
                                            .font(Font.custom("Poppins-Regular", size: 14))
                                    }
                                    Text("22 Reviews \(Image(systemName: "chevron.right"))")
                                        .font(Font.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(.grey)
                                }

                                Spacer()

                                Circle()
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.white)
                                    .overlay {
                                        Circle()
                                            .frame(width: 30, height: 30)
                                    }

                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background {
                                Rectangle()
                                    .foregroundColor(.blue)
                            }
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        ProductDetailTabs(viewModel: self.viewModel)

                        Text("Similar Products")
                            .font(Font.custom("Poppins-SemiBold", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                ForEach(self.viewModel.similarProducts, id: \.id) { product in
                                    ProductCardView(product: product)
                                }
                            }
                            .padding(50)
                        }
                        .padding(-50)
                        
                    }
                    .padding(20)
                }
                .background {
                    Color.white
                }
                .cornerRadius(20)
            }
        }
        .overlay(alignment: .top) {
            HStack {
                Button {
                    _ = self.appState.path.popLast()
                } label: {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                        .opacity(0.2)
                        .overlay {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                        }
                }
                Spacer()
            }
            .padding([.leading, .trailing], 20)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                if let product = self.product {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.background, lineWidth: 1)
                        .frame(width: 55, height: 55)
                        .overlay {
                            LikeButton(enabled: product.isFavorite ?? false)
                        }
                }
                
                Button {
                    
                    if !self.bag.bagProducts.contains(where: { bagProduct in
                        bagProduct.product.id == self.product!.id
                    }) {
                        self.bag.bagProducts.append(BagProduct(product: self.product!, quantity: count))
                        self.bag.totalItems += self.count
                    } else {
                        // Get the index of the existing product that matches product being added
                        let indexOfExisting = self.bag.bagProducts.firstIndex { bagProduct in
                            bagProduct.product.id == self.product!.id
                        }
                        // If the index was not found, return
                        guard let i = indexOfExisting else {
                            print("Failed to get local index of existing product")
                            return
                        }
                        self.bag.bagProducts[i].quantity += self.count
                        self.bag.totalItems += self.count
                    }
                    
                    if !self.bag.categories.contains(where: { category in
                        category == self.product!.categoryID
                    }) {
                        self.bag.categories.append(self.product!.categoryID)
                    }
//                    let keyExists = self.bag.categories[self.product!.categoryID] != nil
//
//                    if keyExists {
//                        self.bag.categories[self.product!.categoryID]! += 1
//                    } else {
//                        self.bag.categories[self.product!.categoryID] = 1
//                    }
                    
                    print(self.bag.bagProducts)
                } label: {
                    Text("Add to bag")
                }
                .buttonStyle(PrimaryButton(width: .infinity))
            }
            .padding([.top, .leading, .trailing])
            .background {
                Color.white.ignoresSafeArea()
            }
            .overlay(Rectangle().frame(height: 1).padding(.top, -1).foregroundColor(Color.background), alignment: .top)
        }
        .navigationBarHidden(true)
        .onAppear {
            print(self.appState.path)
            Task {
                try await self.viewModel.fetchProductDetails()
                try await self.viewModel.fetchSimilarProducts()
            }
        }
    }
}
