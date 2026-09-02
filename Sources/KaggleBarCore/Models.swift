import SwiftUI
import Foundation

// MARK: - App Preferences / Display Modes

public enum MenuBarDisplayMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case gpuQuota = "GPU Quota"
    case username = "Username"
    case both = "Both"
    case iconOnly = "Icon Only"

    public var id: String { rawValue }
}

// MARK: - Models

public struct KaggleAccountItem: Identifiable, Hashable, Sendable {
    public var id: String { username }
    public let username: String
    public let isOAuth: Bool
    public let key: String?

    public init(username: String, isOAuth: Bool, key: String?) {
        self.username = username
        self.isOAuth = isOAuth
        self.key = key
    }
}

public struct KaggleCredential: Codable, Identifiable, Hashable, Sendable {
    public var id: String { username }
    public let username: String
    public let key: String

    public init(username: String, key: String) {
        self.username = username
        self.key = key
    }
}

public struct KaggleConfig: Codable, Sendable {
    public var active: String?
    public var accounts: [String: KaggleCredential]

    public init(active: String?, accounts: [String: KaggleCredential]) {
        self.active = active
        self.accounts = accounts
    }
}

public struct KaggleOAuthCredentials: Codable, Sendable {
    public let username: String?
}

public struct KaggleKernel: Codable, Identifiable, Sendable {
    public var id: String { ref ?? UUID().uuidString }
    public let ref: String?          // "owner/kernel-slug"
    public let title: String?
    public let status: String?       // "running", "queued", "complete", "error"
    public let lastRunTime: String?  // ISO 8601
    public let language: String?
    public let kernelType: String?   // "notebook", "script"

    public var isActive: Bool {
        status == "running" || status == "queued"
    }

    public var statusColor: Color {
        switch status {
        case "running":  return .green
        case "queued":   return .orange
        case "error":    return .red
        default:         return .secondary.opacity(0.5)
        }
    }

    public var relativeTime: String {
        guard let dateStr = lastRunTime else { return "" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var parsedDate = formatter.date(from: dateStr)
        if parsedDate == nil {
            formatter.formatOptions = [.withInternetDateTime]
            parsedDate = formatter.date(from: dateStr)
        }
        guard let date = parsedDate else { return "" }
        let diff = Date().timeIntervalSince(date)
        switch diff {
        case ..<60:         return "just now"
        case ..<3600:      return "\(max(1, Int(diff/60)))m ago"
        case ..<86400:     return "\(max(1, Int(diff/3600)))h ago"
        default:           return "\(max(1, Int(diff/86400)))d ago"
        }
    }

    public var kaggleURL: URL? {
        guard let ref else { return nil }
        return URL(string: "https://www.kaggle.com/code/\(ref)")
    }

    public init(ref: String?, title: String?, status: String?, lastRunTime: String?, language: String?, kernelType: String?) {
        self.ref = ref
        self.title = title
        self.status = status
        self.lastRunTime = lastRunTime
        self.language = language
        self.kernelType = kernelType
    }
}

public struct QuotaItem: Codable, Identifiable, Sendable {
    public var id: String { resource }
    public let resource: String     // "GPU" or "TPU"
    public let used: String         // e.g. "17.17h"
    public let remaining: String    // e.g. "12.83h"
    public let total: String         // e.g. "30.00h"
    public let refreshAt: String?   // "2026-08-22T00:00:00"

    public var usedHours: Double {
        self.parseHours(used)
    }

    public var totalHours: Double {
        self.parseHours(total)
    }

    public var remainingHours: Double {
        self.parseHours(remaining)
    }

    public func parseHours(_ str: String) -> Double {
        let clean = str.replacingOccurrences(of: "h", with: "").trimmingCharacters(in: .whitespaces)
        return Double(clean) ?? 0.0
    }

    public var progress: Double {
        guard totalHours > 0 else { return 0.0 }
        return min(1.0, max(0.0, usedHours / totalHours))
    }

    public init(resource: String, used: String, remaining: String, total: String, refreshAt: String?) {
        self.resource = resource
        self.used = used
        self.remaining = remaining
        self.total = total
        self.refreshAt = refreshAt
    }
}

// REST API Quota Schema

public struct ApiAcceleratorQuotaRaw: Codable, Sendable {
    public let timeUsed: String?
    public let totalTimeAllowed: String?

    public init(timeUsed: String?, totalTimeAllowed: String?) {
        self.timeUsed = timeUsed
        self.totalTimeAllowed = totalTimeAllowed
    }

    public func parseHours(_ str: String?) -> Double {
        guard let s = str else { return 0.0 }
        let clean = s.replacingOccurrences(of: "s", with: "")
        if let seconds = Double(clean) {
            return seconds / 3600.0
        }
        return 0.0
    }
}

public struct ApiQuotaResponseRaw: Codable, Sendable {
    public let quotaRefreshTime: String?
    public let gpuQuota: ApiAcceleratorQuotaRaw?
    public let tpuQuota: ApiAcceleratorQuotaRaw?

    public init(quotaRefreshTime: String?, gpuQuota: ApiAcceleratorQuotaRaw?, tpuQuota: ApiAcceleratorQuotaRaw?) {
        self.quotaRefreshTime = quotaRefreshTime
        self.gpuQuota = gpuQuota
        self.tpuQuota = tpuQuota
    }
}
