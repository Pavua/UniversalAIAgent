import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

extension Color {
    /// Инициализирует Color из hex-строки (#RRGGBB или #RGB)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, (int >> 8) & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, (int >> 24) & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }

    /// Конвертирует Color в hex-строку (#RRGGBB)
    func toHex() -> String? {
        #if canImport(AppKit)
        let nsColor = NSColor(self)
        guard let rgb = nsColor.usingColorSpace(.deviceRGB) else { return nil }
        let r = UInt(round(rgb.redComponent * 255))
        let g = UInt(round(rgb.greenComponent * 255))
        let b = UInt(round(rgb.blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
        #else
        return nil
        #endif
    }
} 