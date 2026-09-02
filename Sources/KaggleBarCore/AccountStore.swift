import Foundation

public struct KaggleAccountsSnapshot {
    public let credentials: [KaggleCredential]
    public let allAccounts: [KaggleAccountItem]
    public let activeAccount: String?

    public init(credentials: [KaggleCredential], allAccounts: [KaggleAccountItem], activeAccount: String?) {
        self.credentials = credentials
        self.allAccounts = allAccounts
        self.activeAccount = activeAccount
    }
}

public final class AccountStore {
    public let paths: KagglePaths

    public struct KagglePaths {
        public let kaggleDir: URL
        public let accountsFileURL: URL
        public let kaggleJsonURL: URL
        public let credentialsFileURL: URL

        public init(kaggleDir: URL) {
            self.kaggleDir = kaggleDir
            self.accountsFileURL = kaggleDir.appendingPathComponent("accounts.json")
            self.kaggleJsonURL = kaggleDir.appendingPathComponent("kaggle.json")
            self.credentialsFileURL = kaggleDir.appendingPathComponent("credentials.json")
        }

        public static var `default`: KagglePaths {
            let home = FileManager.default.homeDirectoryForCurrentUser
            return KagglePaths(kaggleDir: home.appendingPathComponent(".kaggle"))
        }
    }

    public init(paths: KagglePaths = .default) {
        self.paths = paths
    }

    // MARK: - Directory Setup

    public func setupDirectory() {
        try? FileManager.default.createDirectory(at: paths.kaggleDir, withIntermediateDirectories: true)

        // 1. Import existing ~/.kaggle/kaggle.json if present and accounts.json is missing
        if !FileManager.default.fileExists(atPath: paths.accountsFileURL.path) && FileManager.default.fileExists(atPath: paths.kaggleJsonURL.path) {
            if let data = try? Data(contentsOf: paths.kaggleJsonURL),
               let cred = try? JSONDecoder().decode(KaggleCredential.self, from: data) {
                let initial = KaggleConfig(active: cred.username, accounts: [cred.username: cred])
                if let encoded = try? JSONEncoder().encode(initial) {
                    try? encoded.write(to: paths.accountsFileURL)
                    try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: paths.accountsFileURL.path)
                }
            }
        }
    }

    // MARK: - Loading

    public func loadAccounts() -> KaggleAccountsSnapshot {
        var items: [KaggleAccountItem] = []
        var oauthUser: String? = nil
        var credentials: [String: KaggleCredential] = [:]
        var activeAccount: String? = nil

        // 1. Read OAuth account from ~/.kaggle/credentials.json
        if FileManager.default.fileExists(atPath: paths.credentialsFileURL.path),
           let data = try? Data(contentsOf: paths.credentialsFileURL),
           let oauth = try? JSONDecoder().decode(KaggleOAuthCredentials.self, from: data),
           let user = oauth.username, !user.isEmpty {
            oauthUser = user
            items.append(KaggleAccountItem(username: user, isOAuth: true, key: nil))
        }

        // 2. Read accounts from accounts.json
        if let data = try? Data(contentsOf: paths.accountsFileURL),
           let config = try? JSONDecoder().decode(KaggleConfig.self, from: data) {
            credentials = config.accounts
            for (user, cred) in config.accounts {
                if !items.contains(where: { $0.username == user }) {
                    items.append(KaggleAccountItem(username: user, isOAuth: false, key: cred.key))
                }
            }
            if activeAccount == nil {
                activeAccount = config.active
            }
        }

        // 3. Read legacy ~/.kaggle/kaggle.json if present
        if FileManager.default.fileExists(atPath: paths.kaggleJsonURL.path),
           let data = try? Data(contentsOf: paths.kaggleJsonURL),
           let cred = try? JSONDecoder().decode(KaggleCredential.self, from: data) {
            if !items.contains(where: { $0.username == cred.username }) {
                items.append(KaggleAccountItem(username: cred.username, isOAuth: false, key: cred.key))
            }
            if activeAccount == nil {
                activeAccount = cred.username
            }
        }

        // Default active account if not set
        if activeAccount == nil {
            activeAccount = oauthUser ?? items.first?.username
        }

        let credList = credentials.values.sorted { $0.username < $1.username }
        return KaggleAccountsSnapshot(credentials: credList, allAccounts: items, activeAccount: activeAccount)
    }

    // MARK: - Saving

    private func saveConfig(accounts: [String: KaggleCredential], activeAccount: String?) {
        let config = KaggleConfig(active: activeAccount, accounts: accounts)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(config) {
            try? data.write(to: paths.accountsFileURL)
            try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: paths.accountsFileURL.path)
        }
    }

    private func writeKaggleJSON(_ credential: KaggleCredential?) {
        guard let credential else { return }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(credential) {
            try? data.write(to: paths.kaggleJsonURL)
            try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: paths.kaggleJsonURL.path)
        }
    }

    // MARK: - Account Operations

    public func switchAccount(to username: String, accounts: [String: KaggleCredential]) -> KaggleAccountsSnapshot {
        writeKaggleJSON(accounts[username])
        saveConfig(accounts: accounts, activeAccount: username)
        return loadAccounts()
    }

    public func addAccount(username: String, key: String) -> KaggleAccountsSnapshot {
        let snapshot = loadAccounts()
        var accounts = snapshot.credentials.reduce(into: [String: KaggleCredential]()) { result, cred in
            result[cred.username] = cred
        }

        let cleanUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanUser.isEmpty, !cleanKey.isEmpty else {
            return snapshot
        }

        let cred = KaggleCredential(username: cleanUser, key: cleanKey)
        accounts[cleanUser] = cred

        saveConfig(accounts: accounts, activeAccount: cleanUser)
        writeKaggleJSON(cred)
        return loadAccounts()
    }

    public func deleteAccount(username: String) -> KaggleAccountsSnapshot {
        let snapshot = loadAccounts()
        var accounts = snapshot.credentials.reduce(into: [String: KaggleCredential]()) { result, cred in
            result[cred.username] = cred
        }
        accounts.removeValue(forKey: username)

        let newActive: String?
        if snapshot.activeAccount == username {
            newActive = snapshot.allAccounts.first(where: { $0.username != username })?.username
            saveConfig(accounts: accounts, activeAccount: newActive)
            if let newActive, let cred = accounts[newActive] {
                writeKaggleJSON(cred)
            }
        } else {
            newActive = snapshot.activeAccount
            saveConfig(accounts: accounts, activeAccount: newActive)
        }

        return loadAccounts()
    }
}
