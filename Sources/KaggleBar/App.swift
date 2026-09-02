import SwiftUI
import KaggleBarCore

@main
struct KaggleBarApp: App {
    @State private var manager = KaggleManager()

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
