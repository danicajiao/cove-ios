//
//  CategoryCard.swift
//  Cove
//
//  Created by Daniel Cajiao on 6/12/26.
//

import SwiftUI

/// A homepage category card driven by `GET /recommendations/categories`.
///
/// Renders a card with a background image derived from the category path, an SF Symbol
/// chosen from the category's top-level ltree path, and the category name. Tapping navigates
/// to the scoped discovery results and reports the tap via `onTap` (used to post a
/// `category_tap` attention event).
///
/// ## Image key derivation
/// `RecommendedCategory` has no `image_key` field, so the key is derived client-side from the
/// ltree path: join segments with `-`, replace underscores with `-`, lowercase, and wrap in
/// `images/categories/…jpg`. Example: `alcohol.beer` → `images/categories/alcohol-beer.jpg`.
/// Only top-level and mid-level categories (59 total) have images — leaf categories will
/// receive a 404 and fall back to the text-only card, which is intentional.
///
/// The icon is keyed only on the top-level path segment (`food`, `music`, …)
/// so all 160+ leaf categories resolve without per-category assets. Unknown
/// segments fall back to a generic tag icon.
struct CategoryCard: View {
    let category: Components.Schemas.RecommendedCategory
    let onTap: () -> Void

    @Environment(\.imageRepository) private var imageRepository

    @State private var imageURL: URL?
    @State private var imageLoaded = false

    private let width: CGFloat = 130
    private let height: CGFloat = 60

    var body: some View {
        NavigationLink(value: Path.categoryResults(path: category.path, name: category.name)) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(TapGesture().onEnded { onTap() })
        .task(id: category.path) {
            await fetchImage()
        }
    }

    private var parentLabel: String? {
        let segments = category.path.split(separator: ".").map(String.init)
        guard segments.count >= 2 else { return nil }
        return segments[segments.count - 2].replacingOccurrences(of: "_", with: " ").capitalized
    }

    /// Derives a Garage image key from the category's ltree path.
    ///
    /// Joins ltree segments with `-`, replaces underscores with `-`, lowercases, and
    /// wraps in `images/categories/…jpg`. Example: `alcohol.beer` → `images/categories/alcohol-beer.jpg`.
    /// Leaf categories (3+ segments) intentionally produce a key that returns 404, causing a
    /// graceful fallback to the text-only card.
    private var derivedImageKey: String {
        let slug = category.path
            .replacingOccurrences(of: ".", with: "-")
            .replacingOccurrences(of: "_", with: "-")
            .lowercased()
        return "images/categories/\(slug).jpg"
    }

    private var cardContent: some View {
        ZStack(alignment: .topLeading) {
            // Background: image layer (shown only when loaded) or neutral fill
            backgroundLayer

            // Dark gradient overlay for text legibility when image is present
            if imageLoaded {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.55)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            // Foreground card content
            foregroundContent
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.Colors.Strokes.primary, lineWidth: 1)
        }
        .customShadow()
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        if let imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                        .onAppear { imageLoaded = true }
                case .failure:
                    Color.Colors.Fills.quinary
                        .frame(width: width, height: height)
                case .empty:
                    // Loading skeleton
                    Color.Colors.Fills.quinary
                        .frame(width: width, height: height)
                        .overlay {
                            ProgressView()
                                .tint(Color.Colors.Text.tertiary)
                        }
                @unknown default:
                    Color.Colors.Fills.quinary
                        .frame(width: width, height: height)
                }
            }
        } else {
            // No image (nil imageURL = fetch pending or failed) — neutral surface
            Color.Colors.Fills.quinary
                .frame(width: width, height: height)
        }
    }

    private var foregroundContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Image(systemName: Self.symbol(forPath: category.path))
                .font(.system(size: 22))
                .foregroundStyle(imageLoaded ? Color.Colors.Text.inverse : Color.Colors.Brand.accent)

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 2) {
                if let parent = parentLabel {
                    Text(parent)
                        .font(Font.custom("Lato-Regular", size: 10))
                        .foregroundStyle(imageLoaded ? Color.Colors.Text.inverse.opacity(0.8) : Color.Colors.Text.tertiary)
                        .lineLimit(1)
                }

                Text(category.name)
                    .font(Font.custom("Gazpacho-Black", size: 14))
                    .foregroundStyle(imageLoaded ? Color.Colors.Text.inverse : Color.Colors.Text.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(Spacing.md)
        .frame(width: width, height: height, alignment: .topLeading)
    }

    /// Maps a category's top-level ltree segment to an SF Symbol.
    static func symbol(forPath path: String) -> String {
        let root = path.split(separator: ".").first.map(String.init) ?? path
        switch root {
        case "food": return "fork.knife"
        case "alcohol": return "wineglass.fill"
        case "apparel": return "tshirt.fill"
        case "home": return "house.fill"
        case "plants": return "leaf.fill"
        case "beauty": return "sparkles"
        case "art": return "paintpalette.fill"
        case "pets": return "pawprint.fill"
        case "music": return "music.note"
        default: return "tag.fill"
        }
    }

    private func fetchImage() async {
        let key = derivedImageKey
        imageLoaded = false
        imageURL = nil
        imageURL = try? await imageRepository.imageURL(for: key, width: 390, height: 180)
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: Spacing.md) {
            // Mid-level category — has an image
            CategoryCard(
                category: .init(id: "1", name: "Beer", path: "alcohol.beer"),
                onTap: {}
            )
            // Mid-level category with underscore in path — has an image
            CategoryCard(
                category: .init(id: "2", name: "Baked Goods", path: "food.baked_goods"),
                onTap: {}
            )
            // Top-level category — has an image
            CategoryCard(
                category: .init(id: "3", name: "Food", path: "food"),
                onTap: {}
            )
            // Deep leaf category — 404s gracefully, shows text-only fallback
            CategoryCard(
                category: .init(id: "4", name: "Accessories", path: "pets.dogs.accessories"),
                onTap: {}
            )
        }
        .padding()
    }
    .background(Color.Colors.Backgrounds.primary)
}
