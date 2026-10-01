import SwiftUI
import UIKit

// Tokens from the Summit Design System (design/design-system.md).
// Two themes that follow the sky: Day (sunrise–sunset) and Night.

enum SkyTheme: String {
    case day, night

    var palette: Palette { self == .day ? .day : .night }
    var colorScheme: ColorScheme { self == .day ? .light : .dark }

    /// v1 rule: 07:00–19:00 local time is Day. Later: real sunrise/sunset for the user's location.
    static func at(_ date: Date, calendar: Calendar = .current) -> SkyTheme {
        let hour = calendar.component(.hour, from: date)
        return (7..<19).contains(hour) ? .day : .night
    }
}

struct Palette {
    let surface0: Color
    let surface1: Color
    let surface2: Color
    let line: Color
    let ink: Color
    let inkMuted: Color
    let inkFaint: Color
    let action: Color
    let onAction: Color
    let sun: Color
    let onSun: Color
    let sunText: Color
    let glacier: Color
    let success: Color
    let danger: Color

    static let day = Palette(
        surface0: Color(hex: 0xF2F4F7), surface1: Color(hex: 0xFFFFFF), surface2: Color(hex: 0xE7EBF0),
        line: Color(hex: 0xD6DCE4), ink: Color(hex: 0x121A28), inkMuted: Color(hex: 0x566174),
        inkFaint: Color(hex: 0x8A94A3), action: Color(hex: 0x121A28), onAction: Color(hex: 0xFFFFFF),
        sun: Color(hex: 0xF2B33D), onSun: Color(hex: 0x2B1D04), sunText: Color(hex: 0x8A5A00),
        glacier: Color(hex: 0x2D6CB0), success: Color(hex: 0x23804F), danger: Color(hex: 0xC23B2B))

    static let night = Palette(
        surface0: Color(hex: 0x0B1120), surface1: Color(hex: 0x151D31), surface2: Color(hex: 0x1F2840),
        line: Color(hex: 0x2B3552), ink: Color(hex: 0xEEF2F8), inkMuted: Color(hex: 0xA2ADC0),
        inkFaint: Color(hex: 0x69748B), action: Color(hex: 0xEEF2F8), onAction: Color(hex: 0x0B1120),
        sun: Color(hex: 0xF2B33D), onSun: Color(hex: 0x2B1D04), sunText: Color(hex: 0xF5C462),
        glacier: Color(hex: 0x8DB9EA), success: Color(hex: 0x6BCB96), danger: Color(hex: 0xFF8C7A))
}

/// Climber body colours. Only ever used on climbers and their dots, never on UI chrome.
enum ClimberColor: String, CaseIterable, Codable {
    case glacier, lagoon, moss, sunflower, ember, coral, berry, plum

    var hex: UInt32 {
        switch self {
        case .glacier: return 0x3D7FD9
        case .lagoon: return 0x24A094
        case .moss: return 0x5C9E3E
        case .sunflower: return 0xE5B020
        case .ember: return 0xE8702A
        case .coral: return 0xE05A5A
        case .berry: return 0xD6457A
        case .plum: return 0x8E5BD0
        }
    }
    var color: Color { Color(hex: hex) }
    var uiColor: UIColor { UIColor(hex: hex) }
}

enum Radius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum Spacing {
    static let s1: CGFloat = 4
    static let s2: CGFloat = 8
    static let s3: CGFloat = 12
    static let s4: CGFloat = 16
    static let s5: CGFloat = 24
    static let s6: CGFloat = 32
}

private struct PaletteKey: EnvironmentKey {
    static let defaultValue: Palette = .day
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: alpha)
    }
}

// MARK: - Type

extension Font {
    /// Display face (Unbounded) for numbers and mountain names. Falls back to SF Pro Rounded Black.
    static func display(_ size: CGFloat) -> Font {
        if UIFont(name: "Unbounded-Regular", size: size) != nil {
            return .custom("Unbounded-Regular", size: size).weight(.heavy)
        }
        return .system(size: size, weight: .black, design: .rounded)
    }
}

extension UIFont {
    static func rounded(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }
}
