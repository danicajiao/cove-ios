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
    
//    @FirestoreQuery(collectionPath: "products") var products: [Product]
    
    private var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 20),
        GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 20)
    ]
    
    var body: some View {
        let _ = Self._printChanges()
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    // TODO: Implement time-based greeting message
                    Text("Good morning, Daniel")
                        .frame(maxWidth: 215, alignment: .leading)
                        .font(Font.custom("Poppins-SemiBold", size: 26))
                        .padding(EdgeInsets(top: 28, leading: 0, bottom: 0, trailing: 0))
                    Spacer()
                    // TODO: Add notifications button to the right of greeting Text
                    Image(systemName: "bell.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(EdgeInsets(top: 28, leading: 0, bottom: 0, trailing: 0))
                        .foregroundColor(.accent)
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                TextField("\(Image(systemName: "magnifyingglass")) Espresso, light roast, floral", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.grey, lineWidth: 1)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                VStack {
                    HStack {
                        Text("Categories")
                            .font(Font.custom("Poppins-SemiBold", size: 22))
                        Spacer()
                        // TODO: Navigate to Categories scene
                        Button("See all \(Image(systemName: "arrow.forward"))") {
                        }
                        .foregroundColor(.accent)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                LargeButton(category: category)
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    }
                }
                
                VStack {
                    HStack {
                        Text("Featured")
                            .font(Font.custom("Poppins-SemiBold", size: 22))
                        Spacer()
                        // TODO: Navigate to Categories scene
                        Button("See all \(Image(systemName: "arrow.forward"))") {
                        }
                        .foregroundColor(.accent)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    BannerButton(bannerType: 1)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
                
                VStack {
                    HStack {
                        Text("For You")
                            .font(Font.custom("Poppins-SemiBold", size: 22))
                        Spacer()
//                        Button("See all \(Image(systemName: "arrow.forward"))") {
//                        }
//                        .foregroundColor(.accent)
                    }
                    
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
                    
                    
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                BannerButton(bannerType: 2)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                VStack {
                    HStack {
                        Text("Our Favorite Brands")
                            .font(Font.custom("Poppins-SemiBold", size: 22))
                        Spacer()
                        Button("See all \(Image(systemName: "arrow.forward"))") {
                        }
                        .foregroundColor(.accent)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.brands, id: \.id) { brand in
                                VStack {
                                    AsyncImage(url: URL(string: brand.imageURL)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    Text(brand.name)
                                        .font(Font.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(.grey)
                                        .frame(width: 100)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    }
                }
                
//                VStack {
//                    HStack {
//                        Text("Origins")
//                            .font(Font.custom("Poppins-SemiBold", size: 22))
//                        Spacer()
//                        // TODO: Navigate to Browse scene
//                        Button("See all \(Image(systemName: "arrow.forward"))") {
//                        }
//                        .foregroundColor(.accent)
//                    }
//                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
//
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 10) {
//                            ForEach(viewModel.origins, id: \.self) { origin in
//                                OriginButton(origin: origin)
//                            }
//                        }
//                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
//                    }
//                }
            }
        }
        .onAppear {
            print("homeView appeared")
            Task {
                try await viewModel.fetchProducts()
                try await viewModel.fetchBrands()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
