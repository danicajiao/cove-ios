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
    
    let productId: String
    
    @State private var uiImage: UIImage? = nil
    @State private var averageColor: Color = .white // Default background color
    
    @State var count: Int = 1
    
    @State private var index = 0
    @State var viewPagerSize: CGSize = .zero
    
    init(productId: String) {
        self.productId = productId
        self._viewModel = StateObject(wrappedValue: ProductDetailViewModel(productId: productId))
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
        
        return keyWindow?.safeAreaInsets.top ?? 0
    }
    
    private func fetchImage() {
        guard let product = viewModel.product,
              let imageURL = URL(string: product.defaultImageURL) else { return }
        let storageRef = Storage.storage().reference(forURL: imageURL.absoluteString)

        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                return
            }

            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.uiImage = image
                    if let uiColor = image.averageColor {
                        self.averageColor = Color(uiColor) // Convert UIColor to SwiftUI Color
                    }
                }
            }
        }
    }
    
    /// A preference key to store a view's rect
    public struct ViewSizeKey: PreferenceKey {
        public typealias Value = CGSize
        public static var defaultValue = CGSize.zero
        public static func reduce(value: inout Value, nextValue: () -> Value) {
        }
    }
    
    var body: some View {
        Group {
            if let product = viewModel.product {
                // Product loaded, display the details
                ProductDetailContent(
                    product: product,
                    viewModel: viewModel,
                    uiImage: $uiImage,
                    averageColor: $averageColor,
                    count: $count,
                    fetchImage: fetchImage
                )
            } else {
                // Loading state
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading product...")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print(self.appState.path)
        }
    }
}

// Extracted content view to handle the product display
private struct ProductDetailContent: View {
    let product: any Product
    @ObservedObject var viewModel: ProductDetailViewModel
    @Binding var uiImage: UIImage?
    @Binding var averageColor: Color
    @Binding var count: Int
    let fetchImage: () -> Void
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject var bag: Bag
    
    // Computed properties for product-specific info
    var headerStr: String {
        if let coffeeProduct = product as? CoffeeProduct {
            return coffeeProduct.info.roastery
        } else if let musicProduct = product as? MusicProduct {
            return musicProduct.info.artist
        } else if let apparelProduct = product as? ApparelProduct {
            return apparelProduct.info.brand
        }
        return "Header"
    }
    
    var bodyStr: String {
        if let coffeeProduct = product as? CoffeeProduct {
            return coffeeProduct.info.name
        } else if let musicProduct = product as? MusicProduct {
            return musicProduct.info.album
        } else if let apparelProduct = product as? ApparelProduct {
            return apparelProduct.info.name
        }
        return "Body"
    }
    
    var price: Float {
        return product.defaultPrice
    }
    
    func getSafeAreaTop() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        return keyWindow?.safeAreaInsets.top ?? 0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                 VStack {
                     if let uiImage = uiImage {
                         Image(uiImage: uiImage)
                             .resizable()
                             .aspectRatio(contentMode: .fit) // Maintain aspect ratio
                     } else {
                         ProgressView()
                             .frame(maxWidth: .infinity, maxHeight: .infinity)
                             .onAppear {
                                 fetchImage()
                             }
                     }
                 }
                 .frame(height: 300)

                 Group {
                     VStack(spacing: 20) {
                         VStack(spacing: 8) {
                             Text(headerStr)
                                 .font(Font.custom("Gazpacho-Black", size: 22))
                                 .frame(maxWidth: .infinity, alignment: .leading)

                             HStack {
                                 Text("$\(Int(price))")
                                     .font(Font.custom("Lato-Bold", size: 22))
                                     .foregroundStyle(Color.Colors.Fills.primary)

                                 Spacer()
                             }
                         }


                         NavigationLink(destination: Text("Item Reviews!")) {
                             HStack {
                                 VStack(alignment: .leading, spacing: 10) {
                                     HStack {
                                         RatingView(rating: 4)
                                         Text("4.3")
                                             .font(Font.custom("Lato-Regular", size: 14))
                                     }
                                     Text("22 Reviews \(Image(systemName: "chevron.right"))")
                                         .font(Font.custom("Lato-Regular", size: 14))
                                         .foregroundStyle(Color.Colors.Fills.tertiary)
                                 }

                                 Spacer()

                                 Circle()
                                     .frame(width: 35, height: 35)
                                     .foregroundStyle(.white)
                                     .overlay {
                                         Circle()
                                             .frame(width: 30, height: 30)
                                     }

                             }
                             .frame(maxWidth: .infinity, alignment: .leading)
                             .padding(10)
                             .background(.white)
                             .cornerRadius(8)
                             .customShadow()
                         }
                         .buttonStyle(PlainButtonStyle())
                         
                         
                         ProductDetailTabs(viewModel: viewModel)

                         SectionHeader(title: "Similar to this")
                         
                         ScrollView(.horizontal) {
                             HStack(spacing: 20) {
                                 ForEach(viewModel.similarProducts, id: \.id) { product in
                                     ProductCardView(product: product)
                                 }
                             }
                         }
                         
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
                     _ = appState.path.popLast()
                 } label: {
                     RoundedRectangle(cornerRadius: 5)
                         .frame(width: 30, height: 30)
                         .foregroundStyle(.black)
                         .opacity(0.2)
                         .overlay {
                             Image(systemName: "chevron.left")
                                 .foregroundStyle(.white)
                         }
                 }
                 Spacer()
             }
             .padding([.leading, .trailing], 20)
         }
         .safeAreaInset(edge: .bottom) {
             HStack {
                     RoundedRectangle(cornerRadius: 10)
                         .stroke(.gray, lineWidth: 1)
                         .frame(width: 55, height: 55)
                         .overlay {
                             LikeButton(enabled: product.isFavorite ?? false)
                         }
                 
                 Button {
                     
                     if !bag.bagProducts.contains(where: { bagProduct in
                         bagProduct.product.id == product.id
                     }) {
                         bag.bagProducts.append(BagProduct(product: product, quantity: count))
                         bag.totalItems += count
                     } else {
                         // Get the index of the existing product that matches product being added
                         let indexOfExisting = bag.bagProducts.firstIndex { bagProduct in
                             bagProduct.product.id == product.id
                         }
                         // If the index was not found, return
                         guard let i = indexOfExisting else {
                             print("Failed to get local index of existing product")
                             return
                         }
                         bag.bagProducts[i].quantity += count
                         bag.totalItems += count
                     }
                     
                     if !bag.categories.contains(where: { category in
                         category == product.categoryId
                     }) {
                         bag.categories.append(product.categoryId)
                     }
                     
                     print(bag.bagProducts)
                 } label: {
                     Text("Add to bag")
                 }
                 .buttonStyle(PrimaryButton(width: .infinity))
             }
             .padding([.top, .leading, .trailing])
             .background {
                 Color.white.ignoresSafeArea()
             }
             .overlay(Rectangle().frame(height: 1).padding(.top, -1).foregroundStyle(Color.Colors.Fills.quinary), alignment: .top)
         }
    }
}
