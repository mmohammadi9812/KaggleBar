import SwiftUI
import KaggleBarCore

struct MinimalQuotaRow: View {
    let quota: QuotaItem

    private var progressColor: Color {
        if quota.progress > 0.85 {
            return .red
        } else if quota.progress > 0.60 {
            return .orange
        } else {
            return .blue
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(quota.resource)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                Text("\(quota.remaining)")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary)

                Text("/ \(quota.total)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            // Slim progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 4)

                    Capsule()
                        .fill(progressColor)
                        .frame(width: max(0, geo.size.width * CGFloat(quota.progress)), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 2)
    }
}
