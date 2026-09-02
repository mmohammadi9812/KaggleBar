import Foundation
import ArgumentParser
import KaggleBarCore

@main
struct KaggleBarCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "kagglebar",
        abstract: "KaggleBar CLI — Kaggle quota, kernels, accounts, and version",
        version: KaggleBarVersion.appVersion,
        subcommands: [QuotaCommand.self, KernelsCommand.self, AccountsCommand.self, VersionCommand.self]
    )
}

// MARK: - Quota

struct QuotaCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "quota",
        abstract: "Fetch Kaggle GPU/TPU quota"
    )

    func run() async throws {
        let store = AccountStore()
        store.setupDirectory()
        let snapshot = store.loadAccounts()
        let credential = snapshot.activeAccount.flatMap { user in
            snapshot.credentials.first(where: { $0.username == user })
        }
        let status = await KaggleAPI().refresh(credential: credential, activeAccount: snapshot.activeAccount)
        try printJSON(status.quotas)
    }
}

// MARK: - Kernels

struct KernelsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "kernels",
        abstract: "Fetch recent Kaggle kernels"
    )

    func run() async throws {
        let store = AccountStore()
        store.setupDirectory()
        let snapshot = store.loadAccounts()
        let credential = snapshot.activeAccount.flatMap { user in
            snapshot.credentials.first(where: { $0.username == user })
        }
        let status = await KaggleAPI().refresh(credential: credential, activeAccount: snapshot.activeAccount)
        try printJSON(status.kernels)
    }
}

// MARK: - Accounts

struct AccountsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "accounts",
        abstract: "List Kaggle accounts"
    )

    func run() async throws {
        let store = AccountStore()
        store.setupDirectory()
        let snapshot = store.loadAccounts()
        let output = AccountsOutput(
            active: snapshot.activeAccount,
            accounts: snapshot.allAccounts.map {
                AccountEntry(username: $0.username, isOAuth: $0.isOAuth, hasKey: $0.key != nil)
            }
        )
        try printJSON(output)
    }
}

// MARK: - Version

struct VersionCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Print KaggleBar version"
    )

    func run() async throws {
        print(KaggleBarVersion.appVersion)
    }
}

// MARK: - Helpers

struct AccountsOutput: Codable {
    let active: String?
    let accounts: [AccountEntry]
}

struct AccountEntry: Codable {
    let username: String
    let isOAuth: Bool
    let hasKey: Bool
}

private func printJSON<T: Encodable>(_ value: T) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(value)
    if let str = String(data: data, encoding: .utf8) {
        print(str)
    }
}
