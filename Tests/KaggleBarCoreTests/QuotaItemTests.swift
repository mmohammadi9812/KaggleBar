import Testing
@testable import KaggleBarCore

@Test func testParseHoursWithHSuffix() {
    let item = QuotaItem(resource: "GPU", used: "17.17h", remaining: "12.83h", total: "30.00h", refreshAt: nil)
    #expect(abs(item.usedHours - 17.17) < 0.001)
    #expect(abs(item.totalHours - 30.0) < 0.001)
    #expect(abs(item.remainingHours - 12.83) < 0.001)
}

@Test func testParseHoursWithWhitespace() {
    let item = QuotaItem(resource: "GPU", used: " 5.00h ", remaining: "25.00h", total: "30.00h", refreshAt: nil)
    #expect(abs(item.usedHours - 5.0) < 0.001)
    #expect(abs(item.remainingHours - 25.0) < 0.001)
}

@Test func testParseHoursInvalidString() {
    let item = QuotaItem(resource: "GPU", used: "N/A", remaining: "N/A", total: "N/A", refreshAt: nil)
    #expect(item.usedHours == 0.0)
    #expect(item.totalHours == 0.0)
    #expect(item.remainingHours == 0.0)
}

@Test func testProgressCalculation() {
    let item = QuotaItem(resource: "GPU", used: "17.17h", remaining: "12.83h", total: "30.00h", refreshAt: nil)
    #expect(abs(item.progress - 17.17 / 30.0) < 0.001)
}

@Test func testProgressClampedToRange() {
    let overItem = QuotaItem(resource: "GPU", used: "99.00h", remaining: "0.00h", total: "30.00h", refreshAt: nil)
    #expect(overItem.progress >= 0.999)

    let zeroTotal = QuotaItem(resource: "GPU", used: "0.00h", remaining: "0.00h", total: "0.00h", refreshAt: nil)
    #expect(zeroTotal.progress == 0.0)
}

@Test func testParseHoursStandalone() {
    let item = QuotaItem(resource: "GPU", used: "0.00h", remaining: "0.00h", total: "0.00h", refreshAt: nil)
    #expect(abs(item.parseHours("3.50h") - 3.5) < 0.001)
    #expect(abs(item.parseHours("10") - 10.0) < 0.001)
    #expect(item.parseHours("") == 0.0)
    #expect(item.parseHours("abc") == 0.0)
}
