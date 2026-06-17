//
//  FractionalSecondsDateTranscoder.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/20/26.
//

import Foundation
import OpenAPIRuntime

// MARK: - FractionalSecondsDateTranscoder

/// ISO8601 date transcoder that handles fractional seconds (e.g. "2026-06-10T19:52:45.808675Z").
/// The default swift-openapi-generator transcoder uses ISO8601DateFormatter without
/// .withFractionalSeconds, which rejects microsecond-precision timestamps from the API.
struct FractionalSecondsDateTranscoder: DateTranscoder {
    func encode(_ date: Date) throws -> String {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fmt.string(from: date)
    }

    func decode(_ string: String) throws -> Date {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = fmt.date(from: string) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid ISO8601 date: \(string)"))
        }
        return date
    }
}
