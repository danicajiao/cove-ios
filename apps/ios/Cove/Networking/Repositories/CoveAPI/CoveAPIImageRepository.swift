//
//  CoveAPIImageRepository.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/18/26.
//

import Foundation

/// `ImageRepository` backed by cove-api and Garage object storage.
///
/// ## Flow
/// 1. Strips the `images/` prefix from the Garage key to extract the filename.
/// 2. Calls `GET /images/{filename}/url` on cove-api to obtain a short-lived signed
///    imgproxy URL.
/// 3. Returns the URL — caller passes it to `AsyncImage(url:)` or fetches data via `URLSession`.
///
/// ## Key format
/// Callers pass the Garage key directly from the model (`item.defaultImageURL`,
/// `brand.imageURL`). Keys have the form `"images/<sha256>.webp"`. The `images/` prefix is
/// stripped here before forwarding to cove-api — no transformation needed at the call site.
///
/// ## Dimensions
/// `imageURL(for:)` requests 800 × 800 `cover` by default — a reasonable size for
/// all current item and brand image contexts. Call `imageURL(for:width:height:)` directly
/// for a specific size. Per-view dimension support will be formalised in a future issue.
final class CoveAPIImageRepository: ImageRepository {
    // MARK: - Properties

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

    func imageURL(for key: String) async throws -> URL {
        try await imageURL(for: key, width: 800, height: 800)
    }

    /// Returns a signed imgproxy URL for the image at the requested dimensions.
    ///
    /// - Parameters:
    ///   - key: The Garage object key (e.g. `"images/<sha256>.webp"`).
    ///   - width: Output width in pixels (1–4096).
    ///   - height: Output height in pixels (1–4096).
    func imageURL(for key: String, width: Int, height: Int) async throws -> URL {
        guard key.hasPrefix("images/") else {
            throw RepositoryError.notFound
        }

        // Key format: "images/<sha256>.webp" — drop the prefix to get the filename.
        let filename = String(key.dropFirst("images/".count))

        do {
            return try await api.imageURL(filename: filename, width: width, height: height)
        } catch CoveAPIError.unexpectedStatus(404) {
            // The key was valid but the object is gone from Garage.
            throw RepositoryError.notFound
        }
    }
}
