//
//  CategoryCard.swift
//  Cove
//
//  Created by Daniel Cajiao on 6/12/26.
//

import SwiftUI

/// A homepage category card driven by `GET /recommendations/categories`.
///
/// Renders a neutral surface with an SF Symbol chosen from the category's
/// top-level ltree path and the category name. Tapping navigates to the
/// scoped discovery results and reports the tap via `onTap` (used to post a
/// `category_tap` attention event).
///
/// The icon is keyed only on the top-level path segment (`food`, `music`, …)
/// so all 160+ leaf categories resolve without per-category assets. Unknown
/// segments fall back to a generic tag icon.
struct CategoryCard: View {
    let category: Components.Schemas.RecommendedCategory
    let onTap: () -> Void

    private let width: CGFloat = 140
    private let height: CGFloat = 80

    var body: some View {
        NavigationLink(value: Path.categoryResults(path: category.path, name: category.name)) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(TapGesture().onEnded { onTap() })
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Image(systemName: Self.symbol(forPath: category.path))
                .font(.system(size: 22))
                .foregroundStyle(Color.Colors.Brand.accent)

            Spacer(minLength: 0)

            Text(category.name)
                .font(Font.custom("Gazpacho-Black", size: 14))
                .foregroundStyle(Color.Colors.Text.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(Spacing.md)
        .frame(width: width, height: height, alignment: .topLeading)
        .background(Color.Colors.Fills.quinary)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.Colors.Strokes.primary, lineWidth: 1)
        }
        .customShadow()
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
}

#Preview {
    HStack(spacing: Spacing.md) {
        CategoryCard(
            category: .init(id: "1", name: "Whole Bean Coffee", path: "food.coffee.whole_bean"),
            onTap: {}
        )
        CategoryCard(
            category: .init(id: "2", name: "Vinyl", path: "music.recorded"),
            onTap: {}
        )
    }
    .padding()
    .background(Color.Colors.Backgrounds.primary)
}
