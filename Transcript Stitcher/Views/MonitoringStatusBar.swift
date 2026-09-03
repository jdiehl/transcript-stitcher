import SwiftUI

struct MonitoringStatusBar: View {
    let isMonitoring: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMonitoring ? "record.circle.fill" : "pause.circle.fill")
                .foregroundStyle(isMonitoring ? .red : .secondary)
                .symbolEffect(.pulse, isActive: isMonitoring && !reduceMotion)
            
            Text(isMonitoring ? "Monitoring clipboard" : "Clipboard monitoring paused")
                .font(.caption)
                .foregroundStyle(isMonitoring ? .primary : .secondary)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Group {
                if isMonitoring && !reduceMotion {
                    GeometryReader { geo in
                        TimelineView(.animation) { context in
                            let elapsed = context.date.timeIntervalSinceReferenceDate
                            let offset = CGFloat(elapsed.truncatingRemainder(dividingBy: 4) / 4) * geo.size.width
                            
                            let gradient = Gradient(stops: [
                                .init(color: .blue.opacity(0.3), location: 0.0),
                                .init(color: .purple.opacity(0.3), location: 0.125),
                                .init(color: .pink.opacity(0.3), location: 0.25),
                                .init(color: .orange.opacity(0.3), location: 0.375),
                                .init(color: .blue.opacity(0.3), location: 0.5),
                                .init(color: .purple.opacity(0.3), location: 0.625),
                                .init(color: .pink.opacity(0.3), location: 0.75),
                                .init(color: .orange.opacity(0.3), location: 0.875),
                                .init(color: .blue.opacity(0.3), location: 1.0)
                            ])
                            
                            LinearGradient(
                                gradient: gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: geo.size.width * 2)
                            .offset(x: -offset)
                        }
                    }
                } else if isMonitoring {
                    LinearGradient(
                        colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color.secondary.opacity(0.05)
                }
            }
        )
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.separator),
            alignment: .bottom
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isMonitoring ? "Monitoring clipboard" : "Clipboard monitoring paused")
        .accessibilityAddTraits(isMonitoring ? [.updatesFrequently] : [])
    }
}

#Preview("Monitoring") {
    MonitoringStatusBar(isMonitoring: true)
        .frame(width: 400)
}

#Preview("Idle") {
    MonitoringStatusBar(isMonitoring: false)
        .frame(width: 400)
}
