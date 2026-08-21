import SwiftUI
import Foundation
import AppKit
import ServiceManagement

// MARK: - Embedded Assets

struct KaggleAssets {
    private static let menubarIconBase64 = "iVBORw0KGgoAAAANSUhEUgAAABsAAAASCAYAAACq26WdAAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAAGYktHRAAAAAAAAPlDu38AAAAHdElNRQfqCBUMHCWI1Q5WAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDI2LTA4LTIxVDEyOjI0OjA1KzAwOjAw83RCgAAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyNi0wOC0yMVQxMjoyMzo1NCswMDowMI5i5JUAAAAodEVYdGRhdGU6dGltZXN0YW1wADIwMjYtMDgtMjFUMTI6Mjg6MzcrMDA6MDDWEC2nAAAElUlEQVQ4y43UzW9U9R7H8ffv/M7DTOehHdqZAm3tHaHTplZLVYooCuYqPhBkZXTjwoWLu7oaN3d9g/4DGhcmmrg3IRrFp5AYF9WgIqU+UEoLMi30YUrbMzOdc37n/M7vru4CSiif9TffVz7JN1+4Q06ePIkxhhMnTuA4DvcSKSWdnZ14nsf9e/feccbeAr37DuP7xxFC8Morr1bGxsae931/IFIqreMIYwyJMURKCaUiYq21TpINYNKyrK+FJWpzly8zODjI9PT0LbvF7ZgxhnQ6zZEjR45euHDhvVqtVonjCCdXwN29B6ujG2k7mLCJrs3TvH4FHbSwLCuxbftMuq3tX3Ecz2YyaZaXVm5tfztWrVbZv3+8NDEx8dH8/PyD2kBm70PkHnuBqGeYwM4SWimizA66Dxymf2QUf3mJlImE1nqP1jo9ODRwOghCU/frd8dyuRy+7x+cmZl5Uyllpwb24Rw8hqjsQy5fw6gWOluAjiJDBx7j0YdHkB3d9OU9dLPB5uZmvu43PtVa11ut1i27rduxxcVFms3m7kgpzyrsJD92mEPHj9PX30d49ivwa8i+CqXxJ9nV20OpWOQ/r7/MwD+PkWpvB0w+juP2OIq3HMgWLAgCoiiyjbCELD9I34EneGKwh5fKWVwdIlwXJ9MGf/+Of/Y7mq2QOWWxWbyPjVSBMFSWlFIKIbbHtNbEkcJKZ8kP7ePpR0Y4VMwxVvCwSHAdiZw8Q+3j/7J0dRYcyY83fDp7eikMPYywHe04jnZcd/vT/z8mU204nd2M7uzgYCnLuZsONrA58xvh6jL2yOOsPvAMdSV4rjeHAn4pFnGz7dP5nd2rwnaoraxs30ypGNd16Ui7NLSmESeshzGRTmj+fYkkaCK9NKszl6jOXsGRFgXPpr0thZfJzv7j0YP1XcOj99ZMRYokULC+wtSyTybl8eNCgyCB1OhTCB0T/HIGJ11gemeRias1xu7rRLeahOu18erPE13CktVtsTiOUVFM2NggWKyytrjIaZli8noT47aRFHZj7R5Arq2QTP3ASnmYU2dnuDJ7lYU/JtFBq0vqOIuOtm9mjEEppSxjzI7GdZGv11jwu6g1I+Szr5FoQdRWwH7hDTIORPkCq5f/4vdzC6z99D3CEniea7hDtmBCCJRS1y0pg/jmUrp16TxKu8S1DcJEoEOFzBhEqRfPTognf2LH5hpq7hz11WWy2exqLptbh63elg+Sz+expGyEQfBMve73zE//SbJUpa+rA5oNzHqNxL+JnJuEuSnSSYto5ldWLv+JEIJ8Pv/J+x98+Nlv58+bmUv38IiFEGRzuaNhGLyvYz2QJAn5rhKFcgV3Vz+bYYRcXybYWMNfuEJY95G2rTKZzBc9fX3/Dlqt+creCl9/89XdsXK5jOd5XLx4kfb29iGl1ItJklQwJmdZQjq2g+O6RghhBBhLSmVJWXNd79dSd+nb6rXqzcXFGxx98Rjfnv7y7hhAf38/vb29TE1N4fs+AG+9+bYVW1oUO0uUy3vMA6PDjA2PABghhEmlUlSGhpi/VuXQ4af4/NSpLXv/B9mWJQvGvvq1AAAAAElFTkSuQmCC"

    private static let headerLogoBase64 = "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"

    static var menubarImage: Image {
        if let resourceURL = Bundle.main.url(forResource: "menubar_icon", withExtension: "png"),
           let nsImage = NSImage(contentsOf: resourceURL) {
            return Image(nsImage: nsImage)
        }
        if let data = Data(base64Encoded: menubarIconBase64),
           let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        return Image(systemName: "bolt.fill")
    }

    static var logoImage: Image {
        if let resourceURL = Bundle.main.url(forResource: "header_logo", withExtension: "png"),
           let nsImage = NSImage(contentsOf: resourceURL) {
            return Image(nsImage: nsImage)
        }
        if let data = Data(base64Encoded: headerLogoBase64),
           let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        return Image(systemName: "bolt.circle.fill")
    }
}

// MARK: - App Preferences / Display Modes

enum MenuBarDisplayMode: String, CaseIterable, Identifiable {
    case gpuQuota = "GPU Quota"
    case username = "Username"
    case both = "Both"
    case iconOnly = "Icon Only"

    var id: String { rawValue }
}

struct LaunchAtLoginManager {
    static let launchAgentURL: URL = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent("Library/LaunchAgents/com.local.kagglebar.plist")
    }()

    static var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            if SMAppService.mainApp.status == .enabled {
                return true
            }
        }
        return FileManager.default.fileExists(atPath: launchAgentURL.path)
    }

    static func setEnabled(_ enable: Bool) -> Bool {
        if #available(macOS 13.0, *) {
            do {
                if enable {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                    return true
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                    try? FileManager.default.removeItem(at: launchAgentURL)
                    return false
                }
            } catch {
                // Fallback to User LaunchAgent plist
            }
        }

        // Fallback: ~/Library/LaunchAgents/com.local.kagglebar.plist
        if enable {
            let appPath = Bundle.main.bundlePath
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>com.local.kagglebar</string>
                <key>ProgramArguments</key>
                <array>
                    <string>/usr/bin/open</string>
                    <string>\(appPath)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
            </dict>
            </plist>
            """
            let launchAgentsDir = launchAgentURL.deletingLastPathComponent()
            try? FileManager.default.createDirectory(at: launchAgentsDir, withIntermediateDirectories: true)
            try? plistContent.write(to: launchAgentURL, atomically: true, encoding: .utf8)
            return true
        } else {
            try? FileManager.default.removeItem(at: launchAgentURL)
            return false
        }
    }
}

// MARK: - Models

struct KaggleAccountItem: Identifiable, Hashable {
    var id: String { username }
    let username: String
    let isOAuth: Bool
    let key: String?
}

struct KaggleCredential: Codable, Identifiable, Hashable {
    var id: String { username }
    let username: String
    let key: String
}

struct KaggleConfig: Codable {
    var active: String?
    var accounts: [String: KaggleCredential]
}

struct KaggleOAuthCredentials: Codable {
    let username: String?
}

struct KaggleKernel: Codable, Identifiable {
    var id: String { ref ?? UUID().uuidString }
    let ref: String?          // "owner/kernel-slug"
    let title: String?
    let status: String?       // "running", "queued", "complete", "error"
    let lastRunTime: String?  // ISO 8601
    let language: String?
    let kernelType: String?   // "notebook", "script"

    var isActive: Bool {
        status == "running" || status == "queued"
    }

    var statusColor: Color {
        switch status {
        case "running":  return .green
        case "queued":   return .orange
        case "error":    return .red
        default:         return .secondary.opacity(0.5)
        }
    }

    var relativeTime: String {
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
        case ..<3600:       return "\(max(1, Int(diff/60)))m ago"
        case ..<86400:      return "\(max(1, Int(diff/3600)))h ago"
        default:            return "\(max(1, Int(diff/86400)))d ago"
        }
    }

    var kaggleURL: URL? {
        guard let ref else { return nil }
        return URL(string: "https://www.kaggle.com/code/\(ref)")
    }
}

struct QuotaItem: Codable, Identifiable {
    var id: String { resource }
    let resource: String     // "GPU" or "TPU"
    let used: String         // e.g. "17.17h"
    let remaining: String    // e.g. "12.83h"
    let total: String        // e.g. "30.00h"
    let refreshAt: String?   // "2026-08-22T00:00:00"

    var usedHours: Double {
        let clean = used.replacingOccurrences(of: "h", with: "").trimmingCharacters(in: .whitespaces)
        return Double(clean) ?? 0.0
    }

    var totalHours: Double {
        let clean = total.replacingOccurrences(of: "h", with: "").trimmingCharacters(in: .whitespaces)
        return Double(clean) ?? 0.0
    }

    var remainingHours: Double {
        let clean = remaining.replacingOccurrences(of: "h", with: "").trimmingCharacters(in: .whitespaces)
        return Double(clean) ?? 0.0
    }

    var progress: Double {
        guard totalHours > 0 else { return 0.0 }
        return min(1.0, max(0.0, usedHours / totalHours))
    }
}

// REST API Quota Schema
struct ApiAcceleratorQuotaRaw: Codable {
    let timeUsed: String?
    let totalTimeAllowed: String?

    func parseHours(_ str: String?) -> Double {
        guard let s = str else { return 0.0 }
        let clean = s.replacingOccurrences(of: "s", with: "")
        if let seconds = Double(clean) {
            return seconds / 3600.0
        }
        return 0.0
    }
}

struct ApiQuotaResponseRaw: Codable {
    let quotaRefreshTime: String?
    let gpuQuota: ApiAcceleratorQuotaRaw?
    let tpuQuota: ApiAcceleratorQuotaRaw?
}

// MARK: - Kaggle Manager

@MainActor
class KaggleManager: ObservableObject {
    @Published var accounts: [String: KaggleCredential] = [:]
    @Published var allAccounts: [KaggleAccountItem] = []
    @Published var activeAccount: String? = nil
    @Published var quotas: [QuotaItem] = []
    @Published var kernels: [KaggleKernel] = []
    @Published var resetCountdown: String = ""
    @Published var isLoading: Bool = false
    @Published var lastUpdated: Date? = nil

    var displayedKernels: [KaggleKernel] {
        let active = kernels.filter { $0.isActive }
        let recent = kernels.filter { !$0.isActive && $0.status != "cancelAcknowledged" }
        return Array((active + recent).prefix(6))
    }

    // App Preferences
    @Published var displayMode: MenuBarDisplayMode = .gpuQuota {
        didSet {
            UserDefaults.standard.set(displayMode.rawValue, forKey: "displayMode")
        }
    }
    @Published var launchAtLogin: Bool = false

    private let fileManager = FileManager.default
    private let kaggleDir: URL
    private let accountsFileURL: URL
    private let kaggleJsonURL: URL
    private let credentialsFileURL: URL

    init() {
        let home = fileManager.homeDirectoryForCurrentUser
        self.kaggleDir = home.appendingPathComponent(".kaggle")
        self.accountsFileURL = kaggleDir.appendingPathComponent("accounts.json")
        self.kaggleJsonURL = kaggleDir.appendingPathComponent("kaggle.json")
        self.credentialsFileURL = kaggleDir.appendingPathComponent("credentials.json")

        if let savedMode = UserDefaults.standard.string(forKey: "displayMode"),
           let mode = MenuBarDisplayMode(rawValue: savedMode) {
            self.displayMode = mode
        }

        self.launchAtLogin = LaunchAtLoginManager.isEnabled

        setupDirectory()
        loadConfig()
        calculateResetCountdown()

        Task {
            while !Task.isCancelled {
                await refreshStatus()
                try? await Task.sleep(nanoseconds: 600_000_000_000) // Auto-refresh every 10 minutes
            }
        }
    }

    func toggleLaunchAtLogin() {
        let target = !launchAtLogin
        self.launchAtLogin = LaunchAtLoginManager.setEnabled(target)
    }

    private func setupDirectory() {
        try? fileManager.createDirectory(at: kaggleDir, withIntermediateDirectories: true)

        // 1. Import existing ~/.kaggle/kaggle.json if present and accounts.json is missing
        if !fileManager.fileExists(atPath: accountsFileURL.path) && fileManager.fileExists(atPath: kaggleJsonURL.path) {
            if let data = try? Data(contentsOf: kaggleJsonURL),
               let cred = try? JSONDecoder().decode(KaggleCredential.self, from: data) {
                let initial = KaggleConfig(active: cred.username, accounts: [cred.username: cred])
                if let encoded = try? JSONEncoder().encode(initial) {
                    try? encoded.write(to: accountsFileURL)
                    try? fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: accountsFileURL.path)
                }
            }
        }
    }

    func loadConfig() {
        var items: [KaggleAccountItem] = []
        var oauthUser: String? = nil

        // 1. Read OAuth account from ~/.kaggle/credentials.json
        if fileManager.fileExists(atPath: credentialsFileURL.path),
           let data = try? Data(contentsOf: credentialsFileURL),
           let oauth = try? JSONDecoder().decode(KaggleOAuthCredentials.self, from: data),
           let user = oauth.username, !user.isEmpty {
            oauthUser = user
            items.append(KaggleAccountItem(username: user, isOAuth: true, key: nil))
        }

        // 2. Read accounts from accounts.json
        if let data = try? Data(contentsOf: accountsFileURL),
           let config = try? JSONDecoder().decode(KaggleConfig.self, from: data) {
            self.accounts = config.accounts
            for (user, cred) in config.accounts {
                if !items.contains(where: { $0.username == user }) {
                    items.append(KaggleAccountItem(username: user, isOAuth: false, key: cred.key))
                }
            }
            if self.activeAccount == nil {
                self.activeAccount = config.active
            }
        }

        // 3. Read legacy ~/.kaggle/kaggle.json if present
        if fileManager.fileExists(atPath: kaggleJsonURL.path),
           let data = try? Data(contentsOf: kaggleJsonURL),
           let cred = try? JSONDecoder().decode(KaggleCredential.self, from: data) {
            if !items.contains(where: { $0.username == cred.username }) {
                items.append(KaggleAccountItem(username: cred.username, isOAuth: false, key: cred.key))
            }
            if self.activeAccount == nil {
                self.activeAccount = cred.username
            }
        }

        // Default active account if not set
        if self.activeAccount == nil {
            self.activeAccount = oauthUser ?? items.first?.username
        }

        self.allAccounts = items
    }

    private func saveConfig() {
        let config = KaggleConfig(active: activeAccount, accounts: accounts)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(config) {
            try? data.write(to: accountsFileURL)
            try? fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: accountsFileURL.path)
        }
    }

    func switchAccount(to username: String) {
        self.activeAccount = username

        if let cred = accounts[username] {
            // Write API key account to ~/.kaggle/kaggle.json with 0600 permissions
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            if let data = try? encoder.encode(cred) {
                try? data.write(to: kaggleJsonURL)
                try? fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: kaggleJsonURL.path)
            }
        }

        saveConfig()
        Task { await refreshStatus() }
    }

    func addAccount(username: String, key: String) {
        let cleanUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanUser.isEmpty, !cleanKey.isEmpty else { return }

        let cred = KaggleCredential(username: cleanUser, key: cleanKey)
        accounts[cleanUser] = cred
        saveConfig()
        loadConfig()
        switchAccount(to: cleanUser)
    }

    func deleteAccount(username: String) {
        accounts.removeValue(forKey: username)
        if activeAccount == username {
            activeAccount = allAccounts.first(where: { $0.username != username })?.username
            if let newActive = activeAccount, let cred = accounts[newActive] {
                switchAccount(to: cred.username)
            }
        }
        saveConfig()
        loadConfig()
        Task { await refreshStatus() }
    }

    func calculateResetCountdown(from isoDate: String? = nil) {
        if let dateStr = isoDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            var parsed = formatter.date(from: dateStr)
            if parsed == nil {
                formatter.formatOptions = [.withInternetDateTime]
                parsed = formatter.date(from: dateStr)
            }
            if let target = parsed {
                let diff = target.timeIntervalSince(Date())
                if diff > 0 {
                    let hours = Int(diff) / 3600
                    let days = hours / 24
                    let remainingHours = hours % 24
                    if days > 0 {
                        self.resetCountdown = "in \(days)d \(remainingHours)h"
                    } else {
                        self.resetCountdown = "in \(hours)h"
                    }
                    return
                }
            }
        }

        // Fallback: Gregorian Saturday 00:00 UTC
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = Date()
        let weekday = cal.component(.weekday, from: now) // 7 is Saturday
        var daysToAdd = (7 - weekday)
        if daysToAdd <= 0 { daysToAdd += 7 }
        self.resetCountdown = "in ~\(daysToAdd)d (Sat 00:00 UTC)"
    }

    // MARK: - CLI Helpers
    private func findKaggleCLIPath() -> String? {
        let home = fileManager.homeDirectoryForCurrentUser.path
        let candidates = [
            "\(home)/.local/bin/kaggle",
            "/opt/homebrew/bin/kaggle",
            "/usr/local/bin/kaggle",
            "/usr/bin/kaggle"
        ]
        for path in candidates {
            if fileManager.isExecutableFile(atPath: path) {
                return path
            }
        }
        return nil
    }

    private func fetchQuotaFromCLI() async -> [QuotaItem]? {
        guard let kagglePath = findKaggleCLIPath() else { return nil }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: kagglePath)
                process.arguments = ["quota", "--format", "json"]

                let home = FileManager.default.homeDirectoryForCurrentUser.path
                var env = ProcessInfo.processInfo.environment
                env["PATH"] = "\(home)/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
                process.environment = env

                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = Pipe()

                do {
                    try process.run()
                    process.waitUntilExit()
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    if let decoded = try? JSONDecoder().decode([QuotaItem].self, from: data), !decoded.isEmpty {
                        continuation.resume(returning: decoded)
                        return
                    }
                } catch {}
                continuation.resume(returning: nil)
            }
        }
    }

    private func fetchKernelsFromCLI() async -> [KaggleKernel]? {
        guard let kagglePath = findKaggleCLIPath() else { return nil }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: kagglePath)
                process.arguments = [
                    "kernels", "list",
                    "--mine",
                    "--format", "json",
                    "--page-size", "15",
                    "--sort-by", "dateRun"
                ]

                let home = FileManager.default.homeDirectoryForCurrentUser.path
                var env = ProcessInfo.processInfo.environment
                env["PATH"] = "\(home)/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
                process.environment = env

                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = Pipe()

                do {
                    try process.run()
                    process.waitUntilExit()
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    if let decoded = try? JSONDecoder().decode([KaggleKernel].self, from: data) {
                        continuation.resume(returning: decoded)
                        return
                    }
                } catch {}
                continuation.resume(returning: nil)
            }
        }
    }

    // MARK: - Fetch Status & Quota
    func refreshStatus() async {
        isLoading = true
        loadConfig()
        defer {
            isLoading = false
            lastUpdated = Date()
        }

        // 1. Fetch Quota (Try CLI first, then direct REST API)
        var fetchedQuota = false

        if let cliQuotas = await fetchQuotaFromCLI() {
            self.quotas = cliQuotas
            calculateResetCountdown(from: cliQuotas.first?.refreshAt)
            fetchedQuota = true
        }

        if !fetchedQuota, let active = activeAccount, let cred = accounts[active] {
            if let quotaUrl = URL(string: "https://www.kaggle.com/api/v1/kernels/quota") {
                var request = URLRequest(url: quotaUrl)
                let authStr = "\(cred.username):\(cred.key)"
                if let authData = authStr.data(using: .utf8) {
                    request.setValue("Basic \(authData.base64EncodedString())", forHTTPHeaderField: "Authorization")
                }

                if let (data, response) = try? await URLSession.shared.data(for: request),
                   let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200,
                   let apiQuota = try? JSONDecoder().decode(ApiQuotaResponseRaw.self, from: data) {

                    var items: [QuotaItem] = []
                    if let gpu = apiQuota.gpuQuota {
                        let usedH = gpu.parseHours(gpu.timeUsed)
                        let totalH = gpu.parseHours(gpu.totalTimeAllowed)
                        let remH = max(0.0, totalH - usedH)
                        items.append(QuotaItem(
                            resource: "GPU",
                            used: String(format: "%.2fh", usedH),
                            remaining: String(format: "%.2fh", remH),
                            total: String(format: "%.2fh", totalH),
                            refreshAt: apiQuota.quotaRefreshTime
                        ))
                    }
                    if let tpu = apiQuota.tpuQuota {
                        let usedH = tpu.parseHours(tpu.timeUsed)
                        let totalH = tpu.parseHours(tpu.totalTimeAllowed)
                        let remH = max(0.0, totalH - usedH)
                        items.append(QuotaItem(
                            resource: "TPU",
                            used: String(format: "%.2fh", usedH),
                            remaining: String(format: "%.2fh", remH),
                            total: String(format: "%.2fh", totalH),
                            refreshAt: apiQuota.quotaRefreshTime
                        ))
                    }

                    if !items.isEmpty {
                        self.quotas = items
                        calculateResetCountdown(from: apiQuota.quotaRefreshTime)
                        fetchedQuota = true
                    }
                }
            }
        }

        if !fetchedQuota {
            calculateResetCountdown()
        }

        // 2. Fetch Active & Recent Kernels
        if let cliKernels = await fetchKernelsFromCLI() {
            self.kernels = cliKernels
        } else if let active = activeAccount, let cred = accounts[active] {
            if let url = URL(string: "https://www.kaggle.com/api/v1/kernels/list?mine=true&pageSize=15&sortBy=dateRun") {
                var request = URLRequest(url: url)
                let authStr = "\(cred.username):\(cred.key)"
                if let authData = authStr.data(using: .utf8) {
                    request.setValue("Basic \(authData.base64EncodedString())", forHTTPHeaderField: "Authorization")
                }

                if let (data, response) = try? await URLSession.shared.data(for: request),
                   let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200,
                   let decoded = try? JSONDecoder().decode([KaggleKernel].self, from: data) {
                    self.kernels = decoded
                } else {
                    self.kernels = []
                }
            }
        } else {
            self.kernels = []
        }
    }
}

// MARK: - Minimalist SwiftUI Views

struct MinimalQuotaRow: View {
    let quota: QuotaItem

    private var progressColor: Color {
        if quota.progress > 0.85 {
            return .red
        } else if quota.progress > 0.60 {
            return .orange
        } else {
            return .blue
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(quota.resource)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                Text("\(quota.remaining)")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary)

                Text("/ \(quota.total)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            // Slim progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 4)

                    Capsule()
                        .fill(progressColor)
                        .frame(width: max(0, geo.size.width * CGFloat(quota.progress)), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 2)
    }
}

struct KernelRow: View {
    let kernel: KaggleKernel

    var body: some View {
        Button {
            if let url = kernel.kaggleURL {
                NSWorkspace.shared.open(url)
            }
        } label: {
            HStack(spacing: 6) {
                // Status dot
                Circle()
                    .fill(kernel.statusColor)
                    .frame(width: 6, height: 6)

                // Kernel type icon
                Image(systemName: kernel.kernelType == "script" ? "doc.plaintext" : "note.text")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)

                // Title (truncated)
                Text(kernel.title ?? kernel.ref ?? "Untitled")
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                // Relative time or "Running"
                if kernel.isActive {
                    Text(kernel.status?.capitalized ?? "Running")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(kernel.statusColor)
                } else {
                    Text(kernel.relativeTime)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 1)
        }
        .buttonStyle(.plain)
        .help(kernel.ref ?? "")
    }
}

struct ContentView: View {
    @ObservedObject var manager: KaggleManager
    @State private var showingAddForm = false
    @State private var showingSettings = false
    @State private var inputUsername = ""
    @State private var inputKey = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 7) {
                KaggleAssets.logoImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 18)

                Text("Kaggle")
                    .font(.system(size: 13, weight: .bold))

                if let user = manager.activeAccount {
                    Button(action: {
                        if let url = URL(string: "https://www.kaggle.com/\(user)") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 2) {
                            Text("@\(user)")
                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 8))
                        }
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    .help("Open profile @\(user) on Kaggle")
                }

                Spacer()

                Button(action: {
                    Task { await manager.refreshStatus() }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(manager.isLoading ? 360 : 0))
                        .animation(manager.isLoading ? Animation.linear(duration: 0.8).repeatForever(autoreverses: false) : .default, value: manager.isLoading)
                }
                .buttonStyle(.plain)
                .help("Refresh")
            }

            Divider()

            // Quotas Section
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("ACCELERATORS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.8))
                    Spacer()
                    if !manager.resetCountdown.isEmpty {
                        Text("Resets \(manager.resetCountdown)")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }

                if manager.quotas.isEmpty {
                    Text("Fetching quota...")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(manager.quotas) { quota in
                        MinimalQuotaRow(quota: quota)
                    }
                }
            }
            .padding(8)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(6)

            // Kernels Section (Active & Recent)
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("KERNELS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.8))
                    Spacer()
                    Button {
                        let path = manager.activeAccount != nil ? "https://www.kaggle.com/\(manager.activeAccount!)/code" : "https://www.kaggle.com/code"
                        if let url = URL(string: path) {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 2) {
                            Text("View all")
                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 8))
                        }
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("View Notebooks on Kaggle")
                }

                if manager.displayedKernels.isEmpty {
                    Text("No recent kernels")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 2)
                } else {
                    ForEach(manager.displayedKernels) { kernel in
                        KernelRow(kernel: kernel)
                    }
                }
            }
            .padding(8)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(6)

            Divider()

            // Accounts List
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("ACCOUNTS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.8))
                    Spacer()
                    Button(action: {
                        showingAddForm.toggle()
                        if showingAddForm { showingSettings = false }
                    }) {
                        Image(systemName: showingAddForm ? "chevron.up" : "plus")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Add API Key Account")
                }

                if manager.allAccounts.isEmpty {
                    Text("No accounts found.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                } else {
                    ForEach(manager.allAccounts) { account in
                        HStack(spacing: 6) {
                            Image(systemName: manager.activeAccount == account.username ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 11))
                                .foregroundColor(manager.activeAccount == account.username ? .blue : .secondary.opacity(0.4))

                            Button(action: {
                                if let url = URL(string: "https://www.kaggle.com/\(account.username)") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Text(account.username)
                                    .font(.system(size: 11, weight: manager.activeAccount == account.username ? .semibold : .regular))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                            .buttonStyle(.plain)
                            .help("Open @\(account.username) profile")

                            if account.isOAuth {
                                Text("OAuth")
                                    .font(.system(size: 8, weight: .medium))
                                    .padding(.horizontal, 3)
                                    .padding(.vertical, 1)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundColor(.blue)
                                    .cornerRadius(3)
                            }

                            Spacer()

                            if manager.activeAccount != account.username {
                                Button("Switch") {
                                    manager.switchAccount(to: account.username)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .font(.system(size: 9))
                            }

                            if !account.isOAuth {
                                Button(action: { manager.deleteAccount(username: account.username) }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary.opacity(0.6))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 1)
                    }
                }
            }

            // Inline Add Form
            if showingAddForm {
                VStack(spacing: 6) {
                    TextField("Username", text: $inputUsername)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11))
                    SecureField("API Key", text: $inputKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11))

                    HStack {
                        Button("Cancel") {
                            showingAddForm = false
                            inputUsername = ""
                            inputKey = ""
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)

                        Spacer()

                        Button("Save") {
                            manager.addAccount(username: inputUsername, key: inputKey)
                            showingAddForm = false
                            inputUsername = ""
                            inputKey = ""
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.mini)
                        .disabled(inputUsername.isEmpty || inputKey.isEmpty)
                    }
                }
                .padding(6)
                .background(Color.primary.opacity(0.03))
                .cornerRadius(6)
            }

            // Inline Preferences
            if showingSettings {
                VStack(alignment: .leading, spacing: 6) {
                    Text("PREFERENCES")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.8))

                    // Menu Bar display style
                    HStack {
                        Text("Bar Display:")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Spacer()
                        Picker("", selection: $manager.displayMode) {
                            ForEach(MenuBarDisplayMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.menu)
                        .controlSize(.mini)
                    }

                    // Launch at login
                    Toggle(isOn: Binding(
                        get: { manager.launchAtLogin },
                        set: { _ in manager.toggleLaunchAtLogin() }
                    )) {
                        Text("Launch at Login")
                            .font(.system(size: 10))
                    }
                    .toggleStyle(.checkbox)
                    .controlSize(.mini)
                }
                .padding(6)
                .background(Color.primary.opacity(0.03))
                .cornerRadius(6)
            }

            Divider()

            // Minimal Footer
            HStack(spacing: 8) {
                Button(action: {
                    showingSettings.toggle()
                    if showingSettings { showingAddForm = false }
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11))
                        .foregroundColor(showingSettings ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                .help("App Preferences")

                Spacer()

                Button(action: {
                    if let url = URL(string: "https://twitter.com/MeganRisdal") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Logo: @MeganRisdal")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            }
        }
        .padding(11)
        .frame(width: 270)
    }
}

// MARK: - App Entry Point

@main
struct KaggleBarApp: App {
    @StateObject private var manager = KaggleManager()

    var statusText: String {
        let user = manager.activeAccount ?? "Kaggle"
        let gpuStr = manager.quotas.first(where: { $0.resource == "GPU" })?.remaining ?? ""

        switch manager.displayMode {
        case .gpuQuota:
            return gpuStr.isEmpty ? user : gpuStr
        case .username:
            return user
        case .both:
            return gpuStr.isEmpty ? user : "\(user) · \(gpuStr)"
        case .iconOnly:
            return ""
        }
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView(manager: manager)
        } label: {
            HStack(spacing: 4) {
                KaggleAssets.menubarImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 15)
                if !statusText.isEmpty {
                    Text(statusText)
                        .font(.system(size: 12, weight: .medium))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
