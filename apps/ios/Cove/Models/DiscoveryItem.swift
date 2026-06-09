//
//  DiscoveryItem.swift
//
//  Created by Daniel Cajiao on 6/8/26.
//

import Foundation
import UIKit

/// An item sourced from the cove-api gateway.
///
/// Created from `GET /discovery` (list view) and `GET /items/{id}` (detail view).
/// Image URLs are pre-signed and arrive in the same payload as the item data —
/// no separate `ImageRepository.imageURL(for:)` call is required.
///
/// `CoveAPIItemRepository` returns this type from every protocol method.
/// Views that need the item name, maker, or image can read fields directly
/// rather than downcasting to a category-specific type.
struct DiscoveryItem: Item {
    // MARK: - Item protocol

    var id: String?
    var createdAt: Date?

    /// Category UUID from `ItemDetail.category_id`, or `""` for discovery-list items.
    var categoryId: String

    /// `price_cents / 100`, or `0` when the API omits `price_cents`.
    var defaultPrice: Float

    /// The `md` variant signed URL for the primary image, or `""` when absent.
    /// Prefer `primaryImage.url(forTargetPointSize:scale:)` where available.
    var defaultImageURL: String

    var isFavorite: Bool?

    /// Same as `id` — items from cove-api carry all detail in one response.
    var itemDetailsId: String

    // MARK: - Display

    var name: String
    var makerName: String
    var makerID: String
    var itemDescription: String?

    // MARK: - Pre-signed image variants

    /// Signed imgproxy URLs for list-view sizes (thumb / sm / md).
    /// Populated from `DiscoveryResult.primary_image` or derived from the
    /// primary `ItemMedia` in an `ItemDetail` response.
    var primaryImage: Components.Schemas.ImageVariants?

    /// Full gallery with all five variant sizes. Non-empty only for detail responses.
    var media: [Components.Schemas.ItemMedia]

    // MARK: - Hashable / Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DiscoveryItem, rhs: DiscoveryItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Factory

extension DiscoveryItem {
    /// Creates a `DiscoveryItem` from a `GET /discovery` result.
    init(discovery: Components.Schemas.DiscoveryResult) {
        id = discovery.id
        createdAt = nil
        categoryId = ""
        defaultPrice = Float(discovery.priceCents ?? 0) / 100
        defaultImageURL = discovery.primaryImage?.md ?? ""
        isFavorite = nil
        itemDetailsId = discovery.id

        name = discovery.name
        makerName = discovery.maker.name
        makerID = discovery.maker.id
        itemDescription = discovery.description

        primaryImage = discovery.primaryImage
        media = []
    }

    /// Creates a `DiscoveryItem` from a `GET /items/{id}` response.
    init(detail: Components.Schemas.ItemDetail) {
        id = detail.id
        createdAt = nil
        categoryId = detail.categoryId
        defaultPrice = Float(detail.priceCents ?? 0) / 100
        isFavorite = nil
        itemDetailsId = detail.id

        name = detail.name
        makerName = detail.maker.name
        makerID = detail.maker.id
        itemDescription = detail.description

        media = detail.media

        // Build the primary_image variants from the first primary media item
        let primaryMedia = detail.media.first(where: { $0.role == "primary" })
        if let primaryMediaItem = primaryMedia {
            primaryImage = .init(width: primaryMediaItem.width, height: primaryMediaItem.height, thumb: primaryMediaItem.thumb, sm: primaryMediaItem.sm, md: primaryMediaItem.md)
            defaultImageURL = primaryMediaItem.md
        } else {
            primaryImage = nil
            defaultImageURL = ""
        }
    }
}

// MARK: - ImageVariants variant selection

extension Components.Schemas.ImageVariants {
    /// Picks the smallest variant whose pixel width meets or exceeds the target.
    ///
    /// Based on `docs/MEDIA_ARCHITECTURE.md § Picking variants on iOS`.
    ///
    /// - Parameters:
    ///   - size: Target render size in SwiftUI points.
    ///   - scale: Device pixel scale (defaults to the main screen scale).
    /// - Returns: A signed URL, or `nil` when no variant string is a valid URL.
    func url(forTargetPointSize size: CGFloat, scale: CGFloat = UIScreen.main.scale) -> URL? {
        let target = size * scale
        let candidate: String = switch target {
        case ..<300: thumb
        case ..<600: sm
        default: md
        }
        return URL(string: candidate)
    }
}
