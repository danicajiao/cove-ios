//
//  FavoritesView.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/18/26.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()

    private var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Text("My Favorites")
                        .font(Font.custom("Lato-Bold", size: 26))
                        .padding(.top, 28)
                    Spacer()
                }
                .padding([.leading, .trailing], 20)

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                } else if viewModel.favorites.isEmpty {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.Colors.Backgrounds.secondary)
                        .overlay {
                            Text("Products you save will appear here")
                                .multilineTextAlignment(.center)
                                .font(Font.custom("Lato-Regular", size: 16))
                                .foregroundStyle(Color.Colors.Fills.primary)
                                .padding(50)
                        }
                        .border(Color.Colors.Strokes.primary, width: 1)
                        .frame(height: 300)
                        .padding([.leading, .trailing], 20)
                } else {
                    LazyVGrid(
                        columns: columns,
                        alignment: .center,
                        spacing: 20
                    ) {
                        ForEach(viewModel.favorites, id: \.id) { product in
                            ProductCardView(product: product)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 30)
        }
        .background(Color.Colors.Backgrounds.primary.ignoresSafeArea(.all))
        .onAppear {
            Task {
                try await viewModel.fetchFavorites()
            }
        }
    }
}

#Preview {
    FavoritesView()
}
