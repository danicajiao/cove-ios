//
//  BrandLogo.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/26/26.
//

import SwiftUI

/// Resolves a Garage image key to a signed URL and renders a brand logo.
///
/// Fetches the signed imgproxy URL from the environment `ImageRepository`,
/// then passes it to `AsyncImage`. Sized at 91 × 91 pts to fit inside the
/// 131 × 131 `Circle` frame used in the Stores section of `HomeView`.
struct BrandLogo: View {
    let imageKey: String

    @Environment(\.imageRepository) private var imageRepository

    @State private var imageURL: URL?

    var body: some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 91, height: 91)
        } placeholder: {
            ProgressView()
        }
        .padding(Spacing.xl)
        .task(id: imageKey) {
            imageURL = try? await imageRepository.imageURL(for: imageKey)
        }
    }
}

#Preview {
    Circle()
        .fill(Color.Colors.Fills.inverse)
        .frame(width: 131, height: 131)
        .overlay {
            BrandLogo(imageKey: "images/preview-placeholder.webp")
        }
}
