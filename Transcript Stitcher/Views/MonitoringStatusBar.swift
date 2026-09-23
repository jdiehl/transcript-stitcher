import SwiftUI

struct MonitoringStatusBar: View {
    let isMonitoring: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Layout {
        static let hStackSpacing: CGFloat = 8
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 8
        static let animationCycleDuration: Double = 4
        static let gradientDoubleWidthFactor: CGFloat = 2
        static let separatorHeight: CGFloat = 1
    }

    private enum Opacity {
        static let animatedGradient: Double = 0.3
        static let staticGradient: Double = 0.2
        static let idleBackground: Double = 0.05
    }

    private static let animatedGradientStops: [Gradient.Stop] = [
        .init(color: .blue.opacity(Opacity.animatedGradient), location: 0.0),
        .init(color: .purple.opacity(Opacity.animatedGradient), location: 0.125),
        .init(color: .pink.opacity(Opacity.animatedGradient), location: 0.25),
        .init(color: .orange.opacity(Opacity.animatedGradient), location: 0.375),
        .init(color: .blue.opacity(Opacity.animatedGradient), location: 0.5),
        .init(color: .purple.opacity(Opacity.animatedGradient), location: 0.625),
        .init(color: .pink.opacity(Opacity.animatedGradient), location: 0.75),
        .init(color: .orange.opacity(Opacity.animatedGradient), location: 0.875),
        .init(color: .blue.opacity(Opacity.animatedGradient), location: 1.0)
    ]
    
    var body: some View {
        HStack(spacing: Layout.hStackSpacing) {
            Image(systemName: isMonitoring ? "record.circle.fill" : "pause.circle.fill")
                .foregroundStyle(isMonitoring ? .red : .secondary)
                .symbolEffect(.pulse, isActive: isMonitoring && !reduceMotion)
            
            Text(isMonitoring ? "Monitoring clipboard" : "Clipboard monitoring paused")
                .font(.caption)
                .foregroundStyle(isMonitoring ? .primary : .secondary)
            
            Spacer()
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .padding(.vertical, Layout.verticalPadding)
        .background(
            Group {
                if isMonitoring && !reduceMotion {
                    GeometryReader { geo in
                        TimelineView(.animation) { context in
                            let elapsed = context.date.timeIntervalSinceReferenceDate
                            let offset = CGFloat(elapsed.truncatingRemainder(dividingBy: Layout.animationCycleDuration) / Layout.animationCycleDuration) * geo.size.width
                            
                            let gradient = Gradient(stops: Self.animatedGradientStops)
                            
                            LinearGradient(
                                gradient: gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: geo.size.width * Layout.gradientDoubleWidthFactor)
                            .offset(x: -offset)
                        }
                    }
                } else if isMonitoring {
                    LinearGradient(
                        colors: [.blue.opacity(Opacity.staticGradient), .purple.opacity(Opacity.staticGradient)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color.secondary.opacity(Opacity.idleBackground)
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
