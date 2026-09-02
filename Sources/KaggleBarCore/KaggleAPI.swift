import Foundation

public struct KaggleAPI: Sendable {
    public init() {}

    // MARK: - Public Refresh

    public func refresh(credential: KaggleCredential?, activeAccount: String?) async -> KaggleStatus {
        var quotas: [QuotaItem] = []
        var kernels: [KaggleKernel] = []

        // 1. Fetch Quota (Try CLI first, then direct REST API)
        if let cliQuotas = await fetchQuotaFromCLI() {
            quotas = cliQuotas
        } else if let credential {
            if let apiQuotas = await fetchQuotaFromAPI(credential: credential) {
                quotas = apiQuotas
            }
        }

        let refreshAt = quotas.first?.refreshAt
        let resetCountdown = Self.calculateResetCountdown(from: refreshAt)

        // 2. Fetch Active & Recent Kernels
        if let cliKernels = await fetchKernelsFromCLI() {
            kernels = cliKernels
        } else if let credential {
            if let apiKernels = await fetchKernelsFromAPI(credential: credential) {
                kernels = apiKernels
            } else {
                kernels = []
            }
        } else {
            kernels = []
        }

        return KaggleStatus(
            quotas: quotas,
            kernels: kernels,
            resetCountdown: resetCountdown,
            lastUpdated: Date()
        )
    }

    // MARK: - CLI Fetch

    public func findKaggleCLIPath() -> String? {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let candidates = [
            "\(home)/.local/bin/kaggle",
            "/opt/homebrew/bin/kaggle",
            "/usr/local/bin/kaggle",
            "/usr/bin/kaggle"
        ]
        for path in candidates {
            if FileManager.default.isExecutableFile(atPath: path) {
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

    // MARK: - REST API Fetch

    private func fetchQuotaFromAPI(credential: KaggleCredential) async -> [QuotaItem]? {
        let quotaUrl = URL(string: "https://www.kaggle.com/api/v1/kernels/quota")!
        var request = URLRequest(url: quotaUrl)
        let authStr = "\(credential.username):\(credential.key)"
        if let authData = authStr.data(using: .utf8) {
            request.setValue("Basic \(authData.base64EncodedString())", forHTTPHeaderField: "Authorization")
        }

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200,
              let apiQuota = try? JSONDecoder().decode(ApiQuotaResponseRaw.self, from: data) else {
            return nil
        }

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

        return items.isEmpty ? nil : items
    }

    private func fetchKernelsFromAPI(credential: KaggleCredential) async -> [KaggleKernel]? {
        guard let url = URL(string: "https://www.kaggle.com/api/v1/kernels/list?mine=true&pageSize=15&sortBy=dateRun") else {
            return nil
        }

        var request = URLRequest(url: url)
        let authStr = "\(credential.username):\(credential.key)"
        if let authData = authStr.data(using: .utf8) {
            request.setValue("Basic \(authData.base64EncodedString())", forHTTPHeaderField: "Authorization")
        }

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200,
              let decoded = try? JSONDecoder().decode([KaggleKernel].self, from: data) else {
            return nil
        }

        return decoded
    }

    // MARK: - Reset Countdown (pure date math, testable)

    public static func calculateResetCountdown(from isoDate: String?) -> String {
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
                        return "in \(days)d \(remainingHours)h"
                    } else {
                        return "in \(hours)h"
                    }
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
        return "in ~\(daysToAdd)d (Sat 00:00 UTC)"
    }
}
