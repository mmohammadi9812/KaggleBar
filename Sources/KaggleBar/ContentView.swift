import SwiftUI
import AppKit
import KaggleBarCore

struct ContentView: View {
    @Bindable var manager: KaggleManager
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
