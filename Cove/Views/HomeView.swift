//
//  HomeView.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/16/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    @State var search: String = ""

//    private var columns: [GridItem] = [
//        GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 20),
//        GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 20)
//    ]
    
    private var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    
    var body: some View {
        let _ = Self._printChanges()
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    // TODO: Implement time-based greeting message
                    Text("Good morning, Daniel")
                        .frame(maxWidth: 215, alignment: .leading)
                        .font(Font.custom("Gazpacho-Black", size: 25))
                        .lineSpacing(6) // SwiftUI lineSpacing = Figma line height - Font size
                        .foregroundStyle(Color.Colors.Fills.primary)
                    Spacer()
                    // TODO: Add notifications button to the right of greeting Text
                    Image(systemName: "bell.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color.Colors.Brand.accent)
                }
                .padding(.horizontal, 20)

                CustomTextField(
                    placeholder: "Find records, coffee, home, and more",
                    text: $search,
                    returnKeyType: .next,
                    autocapitalizationType: UITextAutocapitalizationType.none,
                    keyboardType: .default,
                    leftIcon: "magnifyingglass",
                    tag: 0
                )
                .padding(.horizontal, 20)

                
                VStack {
                    SectionHeader(title: "Categories")
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                SmallCategoryButton(category: category)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .scrollClipDisabled()
                }
                
                VStack {
                    SectionHeader(title: "Featured")
                        .padding(.horizontal, 20)
                    
                    BannerButton(bannerType: 1)
                        .padding(.horizontal, 20)
                }
                
                VStack {
                    SectionHeader(title: "Popular")
                    
                    if !viewModel.products.isEmpty {
                        LazyVGrid(
                            columns: columns,
                            alignment: .center,
                            spacing: 20
                        ) {
                            ForEach(viewModel.products, id: \.id) { product in
                                ProductCardView(product: product)
                            }
                        }
                    }
                    
//                    if !viewModel.products.isEmpty {
//                        WaterfallCollection(products: viewModel.products)
//                            // .frame(height: 600) // Adjust height as needed
//                    }
                }
                .padding(.horizontal, 20)
                
                BannerButton(bannerType: 2)
                    .padding(.horizontal, 20)
                
                VStack {
                    SectionHeader(title: "Stores")
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.brands, id: \.id) { brand in
                                VStack(spacing: 5) {
                                    Circle()
                                        .fill(Color.Colors.Fills.secondary)
                                        .stroke(Color.Colors.Strokes.primary, lineWidth: 1)
                                        .frame(width: 161, height: 161)
                                        .overlay {
                                            AsyncImage(url: URL(string: brand.imageURL)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 91, height: 91)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        }
                                    
                                    Text(brand.name)
                                        .font(Font.custom("Lato-Bold", size: 14))
                                        .foregroundStyle(Color.Colors.Fills.primary)
                                        .frame(width: 100)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.top, 30)
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Colors.Backgrounds.primary.ignoresSafeArea(.all))
        .onAppear {
            print("homeView appeared")
            Task {
                try await viewModel.fetchProducts()
                try await viewModel.fetchBrands()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
