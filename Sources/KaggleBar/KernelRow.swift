import SwiftUI
import AppKit
import KaggleBarCore

struct KernelRow: View {
    let kernel: KaggleKernel

    var body: some View {
        Button {
            if let url = kernel.kaggleURL {
                NSWorkspace.shared.open(url)
            }
        } label: {
            HStack(spacing: 6) {
                // Status dot
                Circle()
                    .fill(kernel.statusColor)
                    .frame(width: 6, height: 6)

                // Kernel type icon
                Image(systemName: kernel.kernelType == "script" ? "doc.plaintext" : "note.text")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)

                // Title (truncated)
                Text(kernel.title ?? kernel.ref ?? "Untitled")
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                // Relative time or "Running"
                if kernel.isActive {
                    Text(kernel.status?.capitalized ?? "Running")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(kernel.statusColor)
                } else {
                    Text(kernel.relativeTime)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 1)
        }
        .buttonStyle(.plain)
        .help(kernel.ref ?? "")
    }
}
