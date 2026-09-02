import Foundation
import ServiceManagement

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
