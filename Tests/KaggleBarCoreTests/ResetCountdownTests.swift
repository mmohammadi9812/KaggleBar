import Foundation
import Testing
@testable import KaggleBarCore

@Test func testCalculateResetCountdownFromFutureISODate() {
    let formatter = ISO8601DateFormatter()
    // 5 hours + 5 minutes of buffer to avoid truncation edge cases
    let future = formatter.string(from: Date().addingTimeInterval(3600 * 5 + 300))
    let result = KaggleAPI.calculateResetCountdown(from: future)
    #expect(result == "in 5h", "Expected 'in 5h', got '\(result)'")
}

@Test func testCalculateResetCountdownFromDistantFutureISODate() {
    let formatter = ISO8601DateFormatter()
    // 3 days + 1 hour of buffer to avoid truncation edge cases
    let future = formatter.string(from: Date().addingTimeInterval(3600 * 24 * 3 + 3600))
    let result = KaggleAPI.calculateResetCountdown(from: future)
    #expect(result.hasPrefix("in 3d"), "Expected 'in 3d ...', got '\(result)'")
}

@Test func testCalculateResetCountdownFromPastISODateFallsBack() {
    let formatter = ISO8601DateFormatter()
    let past = formatter.string(from: Date().addingTimeInterval(-3600)) // 1 hour ago
    let result = KaggleAPI.calculateResetCountdown(from: past)
    // Past date should fall back to Saturday UTC estimate
    #expect(result.contains("Sat 00:00 UTC"), "Expected Saturday fallback, got '\(result)'")
}

@Test func testCalculateResetCountdownNilDate() {
    let result = KaggleAPI.calculateResetCountdown(from: nil)
    #expect(result.contains("Sat 00:00 UTC"), "Expected Saturday fallback for nil, got '\(result)'")
}

@Test func testCalculateResetCountdownWithoutFractionalSeconds() {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    // 10 hours + 5 minutes of buffer to avoid truncation
    let future = formatter.string(from: Date().addingTimeInterval(3600 * 10 + 300))
    let result = KaggleAPI.calculateResetCountdown(from: future)
    #expect(result == "in 10h", "Expected 'in 10h', got '\(result)'")
}

@Test func testCalculateResetCountdownMalformedDate() {
    let result = KaggleAPI.calculateResetCountdown(from: "not-a-date")
    #expect(result.contains("Sat 00:00 UTC"), "Expected Saturday fallback for malformed date, got '\(result)'")
}
