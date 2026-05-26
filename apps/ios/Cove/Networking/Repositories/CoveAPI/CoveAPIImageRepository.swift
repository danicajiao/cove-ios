//
//  CoveAPIImageRepository.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/18/26.
//

import FirebaseFirestore
import Foundation

/// `ImageRepository` backed by cove-api and Garage object storage.
///
/// ## Flow
/// 1. Reads the Garage object key (`defaultImageURL`) from the Firestore `products` document.
/// 2. Strips the `images/` prefix to extract the filename.
/// 3. Calls `GET /images/{filename}/url` on cove-api to obtain a short-lived signed
///    imgproxy URL.
/// 4. Returns the URL — caller passes it to `AsyncImage(url:)`.
///
/// ## Interim Firestore dependency
/// Firestore is the source of truth for product data (including image keys) until
/// `cove-product` ships in Phase 3. At that point the Firestore read is replaced by
/// a `cove-product` API call; the cove-image signed-URL step is unchanged.
///
/// ## Dimensions
/// `imageURL(for:)` requests 800 × 800 `cover` by default — a reasonable size for
/// all current product image contexts. Callers that need a specific size should use
/// `imageURL(for:width:height:)` directly. Per-view dimension support will be
/// formalised in `ImageRepository` during #247.
final class CoveAPIImageRepository: ImageRepository {
    // MARK: - Properties

    private let firestore = Firestore.firestore()
    private let api: CoveAPIClient

    // MARK: - Init

    /// Creates a repository using the provided API client.
    ///
    /// - Parameter api: The `CoveAPIClient` to use for signed-URL requests.
    ///   Defaults to `CoveAPIClient.shared`; pass a custom instance in unit tests.
    init(api: CoveAPIClient = .shared) {
        self.api = api
    }

    // MARK: - ImageRepository

    func imageURL(for productId: String) async throws -> URL {
        try await imageURL(for: productId, width: 800, height: 800)
    }

    /// Returns a signed imgproxy URL for the product image at the requested dimensions.
    ///
    /// - Parameters:
    ///   - productId: Firestore document ID of the product.
    ///   - width: Output width in pixels (1–4096).
    ///   - height: Output height in pixels (1–4096).
    func imageURL(for productId: String, width: Int, height: Int) async throws -> URL {
        // ── 1. Fetch the Garage key from Firestore ────────────────────────────
        let snapshot = try await firestore
            .collection("products")
            .document(productId)
            .getDocument()

        guard
            snapshot.exists,
            let key = snapshot["defaultImageURL"] as? String,
            key.hasPrefix("images/")
        else {
            throw RepositoryError.notFound
        }

        // Key format: "images/<sha256>.webp" — drop the prefix to get the filename.
        let filename = String(key.dropFirst("images/".count))

        // ── 2. Get a signed URL from cove-api ─────────────────────────────────
        do {
            return try await api.imageURL(filename: filename, width: width, height: height)
        } catch CoveAPIError.unexpectedStatus(404) {
            // The key exists in Firestore but the object is gone from Garage.
            throw RepositoryError.notFound
        }
    }
}
