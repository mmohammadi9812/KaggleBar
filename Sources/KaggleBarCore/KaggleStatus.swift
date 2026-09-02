import Foundation

public struct KaggleStatus: Sendable {
    public let quotas: [QuotaItem]
    public let kernels: [KaggleKernel]
    public let resetCountdown: String
    public let lastUpdated: Date?

    public init(quotas: [QuotaItem], kernels: [KaggleKernel], resetCountdown: String, lastUpdated: Date?) {
        self.quotas = quotas
        self.kernels = kernels
        self.resetCountdown = resetCountdown
        self.lastUpdated = lastUpdated
    }
}
