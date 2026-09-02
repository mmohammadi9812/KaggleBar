import Foundation
import Testing
@testable import KaggleBarCore

private func withTempDir(_ body: (URL) -> Void) {
    let dir = FileManager.default.temporaryDirectory
        .appendingPathComponent("KaggleBarTest_\(UUID().uuidString)")
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    body(dir)
}

// MARK: - setupDirectory

@Test func testSetupDirectoryCreatesDir() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()
        #expect(FileManager.default.fileExists(atPath: tempDir.path))
    }
}

@Test func testSetupDirectoryImportsLegacyKaggleJSON() {
    withTempDir { tempDir in
        let legacyCred = KaggleCredential(username: "legacyuser", key: "legacykey")
        try! JSONEncoder().encode(legacyCred).write(to: tempDir.appendingPathComponent("kaggle.json"))

        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        // accounts.json should now exist and contain the imported credential
        let accountsData = try? Data(contentsOf: tempDir.appendingPathComponent("accounts.json"))
        #expect(accountsData != nil)
        if let data = accountsData,
           let config = try? JSONDecoder().decode(KaggleConfig.self, from: data) {
            #expect(config.accounts["legacyuser"]?.key == "legacykey")
            #expect(config.active == "legacyuser")
        }
    }
}

@Test func testSetupDirectoryDoesNotOverwriteExistingAccountsJSON() {
    withTempDir { tempDir in
        // Write a pre-existing accounts.json
        let cred = KaggleCredential(username: "existinguser", key: "existingkey")
        let config = KaggleConfig(active: "existinguser", accounts: ["existinguser": cred])
        try! JSONEncoder().encode(config).write(to: tempDir.appendingPathComponent("accounts.json"))

        // Also write a kaggle.json — setupDirectory should NOT import it
        let legacyCred = KaggleCredential(username: "legacyuser", key: "legacykey")
        try! JSONEncoder().encode(legacyCred).write(to: tempDir.appendingPathComponent("kaggle.json"))

        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        let accountsData = try? Data(contentsOf: tempDir.appendingPathComponent("accounts.json"))
        #expect(accountsData != nil)
        if let data = accountsData,
           let decoded = try? JSONDecoder().decode(KaggleConfig.self, from: data) {
            // Should still only have existinguser
            #expect(decoded.accounts.count == 1)
            #expect(decoded.accounts["existinguser"] != nil)
            #expect(decoded.accounts["legacyuser"] == nil)
        }
    }
}

// MARK: - addAccount

@Test func testAddAccountRoundTrip() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        _ = store.addAccount(username: "testuser", key: "testkey123")

        let snapshot = store.loadAccounts()
        #expect(snapshot.credentials.count == 1)
        #expect(snapshot.credentials.first?.username == "testuser")
        #expect(snapshot.credentials.first?.key == "testkey123")
        #expect(snapshot.activeAccount == "testuser")
    }
}

@Test func testAddAccountTrimsWhitespace() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        _ = store.addAccount(username: "  spaceduser  ", key: "  spacedkey  ")

        let snapshot = store.loadAccounts()
        #expect(snapshot.credentials.first?.username == "spaceduser")
        #expect(snapshot.credentials.first?.key == "spacedkey")
    }
}

@Test func testAddAccountRejectsEmpty() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        let snapshot = store.addAccount(username: "", key: "")
        #expect(snapshot.credentials.count == 0)
    }
}

@Test func testAddMultipleAccounts() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        _ = store.addAccount(username: "user1", key: "key1")
        _ = store.addAccount(username: "user2", key: "key2")

        let snapshot = store.loadAccounts()
        #expect(snapshot.credentials.count == 2)
        #expect(snapshot.allAccounts.count == 2)
    }
}

// MARK: - loadAccounts

@Test func testLoadAccountsDetectsOAuthCredentials() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        let oauth = KaggleOAuthCredentials(username: "oauthuser")
        try! JSONEncoder().encode(oauth).write(to: tempDir.appendingPathComponent("credentials.json"))

        let snapshot = store.loadAccounts()
        #expect(snapshot.allAccounts.contains { $0.username == "oauthuser" && $0.isOAuth })
        #expect(snapshot.credentials.count == 0) // OAuth has no API key credential
        #expect(snapshot.activeAccount == "oauthuser")
    }
}

@Test func testLoadAccountsReturnsActiveFromConfig() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        _ = store.addAccount(username: "user1", key: "key1")
        _ = store.addAccount(username: "user2", key: "key2")

        let snapshot = store.loadAccounts()
        // Last added is active
        #expect(snapshot.activeAccount == "user2")
    }
}

// MARK: - switchAccount

@Test func testSwitchAccountWritesKaggleJSON() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        _ = store.addAccount(username: "user1", key: "key1")
        _ = store.addAccount(username: "user2", key: "key2")

        let snapshot = store.loadAccounts()
        let accountsDict = Dictionary(uniqueKeysWithValues: snapshot.credentials.map { ($0.username, $0) })

        let updated = store.switchAccount(to: "user1", accounts: accountsDict)
        #expect(updated.activeAccount == "user1")

        // kaggle.json should contain user1's credentials
        let data = try? Data(contentsOf: tempDir.appendingPathComponent("kaggle.json"))
        #expect(data != nil)
        if let data, let cred = try? JSONDecoder().decode(KaggleCredential.self, from: data) {
            #expect(cred.username == "user1")
            #expect(cred.key == "key1")
        }
    }
}

// MARK: - deleteAccount

@Test func testDeleteAccountRemovesAndSwitches() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        _ = store.addAccount(username: "user1", key: "key1")
        _ = store.addAccount(username: "user2", key: "key2")

        // Delete user2 (the active one)
        let snapshot = store.deleteAccount(username: "user2")
        #expect(snapshot.credentials.count == 1)
        #expect(snapshot.credentials.first?.username == "user1")
        #expect(snapshot.activeAccount == "user1")

        // accounts.json should only have user1
        let data = try? Data(contentsOf: tempDir.appendingPathComponent("accounts.json"))
        #expect(data != nil)
        if let data, let config = try? JSONDecoder().decode(KaggleConfig.self, from: data) {
            #expect(config.accounts.count == 1)
            #expect(config.accounts["user2"] == nil)
        }
    }
}

@Test func testDeleteAccountNonActive() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()

        _ = store.addAccount(username: "user1", key: "key1")
        _ = store.addAccount(username: "user2", key: "key2")

        // Delete user1 (not active)
        let snapshot = store.deleteAccount(username: "user1")
        #expect(snapshot.credentials.count == 1)
        #expect(snapshot.activeAccount == "user2")
    }
}

// MARK: - Isolation

@Test func testNoWritesOutsideTempDir() {
    withTempDir { tempDir in
        let store = AccountStore(paths: AccountStore.KagglePaths(kaggleDir: tempDir))
        store.setupDirectory()
        _ = store.addAccount(username: "testuser", key: "testkey")

        // Verify files only exist in temp dir
        #expect(store.paths.kaggleDir.path.hasPrefix(tempDir.path))
        #expect(FileManager.default.fileExists(atPath: store.paths.accountsFileURL.path))
        #expect(FileManager.default.fileExists(atPath: store.paths.kaggleJsonURL.path))
    }
}
