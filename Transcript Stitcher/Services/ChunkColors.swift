import SwiftUI

enum ChunkColors {
    static let hueStep = 1.0 / 8.0 + 1.0 / 256.0

    static func color(forColorIndex index: Int, colorScheme: ColorScheme) -> Color {
        let hue = (Double(index) * hueStep).truncatingRemainder(dividingBy: 1)
        switch colorScheme {
        case .dark:
            return Color(hue: hue, saturation: 0.6, brightness: 0.85)
        default:
            return Color(hue: hue, saturation: 0.55, brightness: 0.75)
        }
    }
}
