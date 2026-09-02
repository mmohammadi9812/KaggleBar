import Foundation
import KaggleBarCore

struct AppConfig: Codable {
    var displayMode: String?
    var launchAtLogin: Bool?

    static let configURL: URL = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".config/kagglebar/config.json")
    }()

    static func load() -> AppConfig {
        // Try config.json first
        if let data = try? Data(contentsOf: configURL),
           let config = try? JSONDecoder().decode(AppConfig.self, from: data) {
            return config
        }

        // Migrate from UserDefaults on first read
        let migrated = AppConfig(
            displayMode: UserDefaults.standard.string(forKey: "displayMode"),
            launchAtLogin: nil
        )
        // Only save if there was something to migrate
        if migrated.displayMode != nil {
            migrated.save()
        }
        return migrated
    }

    func save() {
        let dir = Self.configURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: dir.path)
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: Self.configURL)
        }
    }
}
