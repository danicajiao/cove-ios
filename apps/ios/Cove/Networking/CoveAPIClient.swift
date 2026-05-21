//
//  CoveAPIClient.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/20/26.
//

import FirebaseAuth
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

// MARK: - CoveAPIClient

/// Typed HTTP client for the cove-api gateway.
///
/// Built on top of the Swift OpenAPI Generator–generated `Client` from the
/// gateway's `openapi.yaml` spec. `CoveAPIClient` adds:
/// - `APIEnvironment`-aware server URL selection (staging in Debug, prod in Release)
/// - Firebase ID Token injection via `FirebaseAuthMiddleware`
///
/// Construct via `CoveAPIClient.shared` for standard use, or pass explicit
/// `serverURL` and `session` parameters in unit tests.
///
/// ```swift
/// let health = try await CoveAPIClient.shared.health()
/// print(health.status) // "ok"
/// ```
final class CoveAPIClient: @unchecked Sendable {
    // MARK: Shared instance

    static let shared = CoveAPIClient()

    // MARK: Private

    private let client: Client

    // MARK: Init

    init(
        serverURL: URL = APIEnvironment.current.baseURL,
        session: URLSession = .shared
    ) {
        let transport = URLSessionTransport(configuration: .init(session: session))
        let middleware = FirebaseAuthMiddleware()
        client = Client(
            serverURL: serverURL,
            transport: transport,
            middlewares: [middleware]
        )
    }

    // MARK: - Endpoints

    /// Calls `GET /health` and returns the gateway health payload.
    ///
    /// This endpoint is unauthenticated — the Firebase Bearer header is forwarded
    /// by `FirebaseAuthMiddleware` but ignored by the gateway for this route.
    /// Used by the iOS launch smoke test (danicajiao/cove#236) to verify tunnel
    /// and gateway reachability before the first user interaction.
    ///
    /// - Returns: A `HealthResponse` with `service`, `status`, and `commit` fields.
    /// - Throws: `CoveAPIError.unexpectedStatus` for undocumented HTTP status codes,
    ///           or any transport error from the underlying `URLSession`.
    func health() async throws -> Components.Schemas.HealthResponse {
        let response = try await client.getHealth()
        switch response {
        case let .ok(okResponse):
            return try okResponse.body.json
        case let .serviceUnavailable(unavailable):
            return try unavailable.body.json
        case let .undocumented(statusCode, _):
            throw CoveAPIError.unexpectedStatus(statusCode)
        }
    }
}

// MARK: - FirebaseAuthMiddleware

/// OpenAPI client middleware that injects a Firebase ID Token as a Bearer
/// credential on every outgoing request.
///
/// Routes that opt out of authentication (e.g. `GET /health`) receive the
/// header anyway — the gateway ignores it for unauthenticated routes.
/// This keeps the middleware unconditional: one path, no per-route branching.
///
/// If no user is currently signed in the request is forwarded without an
/// `Authorization` header. Unauthenticated routes continue to work; protected
/// routes will receive a 401 from the gateway.
private struct FirebaseAuthMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        guard let user = Auth.auth().currentUser else {
            return try await next(request, body, baseURL)
        }

        let result = try await user.getIDTokenResult(forcingRefresh: false)
        var authenticated = request
        authenticated.headerFields[.authorization] = "Bearer \(result.token)"
        return try await next(authenticated, body, baseURL)
    }
}

// MARK: - CoveAPIError

/// Errors surfaced by `CoveAPIClient` for cases outside the documented API contract.
enum CoveAPIError: Error {
    /// The server returned an HTTP status code not defined in `openapi.yaml`.
    case unexpectedStatus(Int)
}

// MARK: - LocalizedError

extension CoveAPIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .unexpectedStatus(code):
            "Unexpected HTTP status code \(code) — not defined in the API contract."
        }
    }
}
