import SwiftUI
import KaggleBarCore

@Observable @MainActor final class KaggleManager {
    // MARK: - Observable State

    var quotas: [QuotaItem] = []
    var kernels: [KaggleKernel] = []
    var resetCountdown: String = ""
    var isLoading: Bool = false
    var lastUpdated: Date? = nil

    var accounts: [String: KaggleCredential] = [:]
    var allAccounts: [KaggleAccountItem] = []
    var activeAccount: String? = nil

    // App Preferences
    var displayMode: MenuBarDisplayMode = .gpuQuota {
        didSet {
            var config = AppConfig.load()
            config.displayMode = displayMode.rawValue
            config.save()
        }
    }

    var launchAtLogin: Bool = false {
        didSet {
            var config = AppConfig.load()
            config.launchAtLogin = launchAtLogin
            config.save()
        }
    }

    // MARK: - Composition

    private let api: KaggleAPI
    private let accountStore: AccountStore

    // MARK: - Init

    init(api: KaggleAPI = KaggleAPI(), paths: AccountStore.KagglePaths = .default) {
        self.api = api
        self.accountStore = AccountStore(paths: paths)

        self.accountStore.setupDirectory()

        let snapshot = self.accountStore.loadAccounts()
        self.accounts = Dictionary(uniqueKeysWithValues: snapshot.credentials.map { ($0.username, $0) })
        self.allAccounts = snapshot.allAccounts
        self.activeAccount = snapshot.activeAccount

        let config = AppConfig.load()
        if let savedMode = config.displayMode.flatMap({ MenuBarDisplayMode(rawValue: $0) }) {
            self.displayMode = savedMode
        }
        self.launchAtLogin = config.launchAtLogin ?? LaunchAtLoginManager.isEnabled

        self.resetCountdown = KaggleAPI.calculateResetCountdown(from: nil)

        Task {
            while !Task.isCancelled {
                await refreshStatus()
                try? await Task.sleep(nanoseconds: 600_000_000_000) // Auto-refresh every 10 minutes
            }
        }
    }

    // MARK: - Derived

    var displayedKernels: [KaggleKernel] {
        let active = kernels.filter { $0.isActive }
        let recent = kernels.filter { !$0.isActive && $0.status != "cancelAcknowledged" }
        return Array((active + recent).prefix(6))
    }

    // MARK: - Actions

    func refreshStatus() async {
        isLoading = true
        defer {
            isLoading = false
            lastUpdated = Date()
        }

        let snapshot = accountStore.loadAccounts()
        accounts = Dictionary(uniqueKeysWithValues: snapshot.credentials.map { ($0.username, $0) })
        allAccounts = snapshot.allAccounts
        activeAccount = snapshot.activeAccount

        let credential = activeAccount.flatMap { accounts[$0] }
        let status = await api.refresh(credential: credential, activeAccount: activeAccount)
        quotas = status.quotas
        kernels = status.kernels
        resetCountdown = status.resetCountdown
    }

    func toggleLaunchAtLogin() {
        let target = !launchAtLogin
        launchAtLogin = LaunchAtLoginManager.setEnabled(target)
    }

    func switchAccount(to username: String) {
        let snapshot = accountStore.switchAccount(to: username, accounts: accounts)
        accounts = Dictionary(uniqueKeysWithValues: snapshot.credentials.map { ($0.username, $0) })
        allAccounts = snapshot.allAccounts
        activeAccount = snapshot.activeAccount
        Task { await refreshStatus() }
    }

    func addAccount(username: String, key: String) {
        let snapshot = accountStore.addAccount(username: username, key: key)
        accounts = Dictionary(uniqueKeysWithValues: snapshot.credentials.map { ($0.username, $0) })
        allAccounts = snapshot.allAccounts
        activeAccount = snapshot.activeAccount
        Task { await refreshStatus() }
    }

    func deleteAccount(username: String) {
        let snapshot = accountStore.deleteAccount(username: username)
        accounts = Dictionary(uniqueKeysWithValues: snapshot.credentials.map { ($0.username, $0) })
        allAccounts = snapshot.allAccounts
        activeAccount = snapshot.activeAccount
        Task { await refreshStatus() }
    }
}
