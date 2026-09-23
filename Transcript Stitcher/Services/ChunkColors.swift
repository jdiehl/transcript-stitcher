import SwiftUI

enum ChunkColors {
    static let hueStep = 1.0 / 8.0 + 1.0 / 256.0

    private enum DarkMode {
        static let saturation: Double = 0.6
        static let brightness: Double = 0.85
    }

    private enum LightMode {
        static let saturation: Double = 0.55
        static let brightness: Double = 0.75
    }

    static func color(forColorIndex index: Int, colorScheme: ColorScheme) -> Color {
        let hue = (Double(index) * hueStep).truncatingRemainder(dividingBy: 1)
        switch colorScheme {
        case .dark:
            return Color(hue: hue, saturation: DarkMode.saturation, brightness: DarkMode.brightness)
        default:
            return Color(hue: hue, saturation: LightMode.saturation, brightness: LightMode.brightness)
        }
    }
}
