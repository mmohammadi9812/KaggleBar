import Foundation
import Testing
@testable import KaggleBarCore

@Test func testIsActiveForRunningAndQueued() {
    let running = KaggleKernel(ref: nil, title: nil, status: "running", lastRunTime: nil, language: nil, kernelType: nil)
    #expect(running.isActive)

    let queued = KaggleKernel(ref: nil, title: nil, status: "queued", lastRunTime: nil, language: nil, kernelType: nil)
    #expect(queued.isActive)
}

@Test func testIsNotActiveForCompleteAndError() {
    let complete = KaggleKernel(ref: nil, title: nil, status: "complete", lastRunTime: nil, language: nil, kernelType: nil)
    #expect(!complete.isActive)

    let error = KaggleKernel(ref: nil, title: nil, status: "error", lastRunTime: nil, language: nil, kernelType: nil)
    #expect(!error.isActive)
}

@Test func testKaggleURL() {
    let kernel = KaggleKernel(ref: "owner/kernel-slug", title: "Test", status: "complete", lastRunTime: nil, language: nil, kernelType: nil)
    #expect(kernel.kaggleURL?.absoluteString == "https://www.kaggle.com/code/owner/kernel-slug")
}

@Test func testKaggleURLOmittedRef() {
    let kernel = KaggleKernel(ref: nil, title: "Test", status: "complete", lastRunTime: nil, language: nil, kernelType: nil)
    #expect(kernel.kaggleURL == nil)
}

@Test func testRelativeTimeJustNow() {
    let recent = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-30))
    let kernel = KaggleKernel(ref: nil, title: nil, status: "complete", lastRunTime: recent, language: nil, kernelType: nil)
    #expect(kernel.relativeTime == "just now")
}

@Test func testRelativeTimeMinutes() {
    let minutesAgo = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-300))
    let kernel = KaggleKernel(ref: nil, title: nil, status: "complete", lastRunTime: minutesAgo, language: nil, kernelType: nil)
    #expect(kernel.relativeTime == "5m ago")
}

@Test func testRelativeTimeHours() {
    let hoursAgo = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200))
    let kernel = KaggleKernel(ref: nil, title: nil, status: "complete", lastRunTime: hoursAgo, language: nil, kernelType: nil)
    #expect(kernel.relativeTime == "2h ago")
}

@Test func testRelativeTimeDays() {
    let daysAgo = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 3))
    let kernel = KaggleKernel(ref: nil, title: nil, status: "complete", lastRunTime: daysAgo, language: nil, kernelType: nil)
    #expect(kernel.relativeTime == "3d ago")
}

@Test func testRelativeTimeInvalidDate() {
    let kernel = KaggleKernel(ref: nil, title: nil, status: "complete", lastRunTime: "not-a-date", language: nil, kernelType: nil)
    #expect(kernel.relativeTime.isEmpty)
}

@Test func testRelativeTimeNoDate() {
    let kernel = KaggleKernel(ref: nil, title: nil, status: "complete", lastRunTime: nil, language: nil, kernelType: nil)
    #expect(kernel.relativeTime.isEmpty)
}
