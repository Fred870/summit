import Foundation

/// Items found along the route. Values are starting points to tune in playtests (product/slc-scope.md).
enum ItemKind: String, Codable, CaseIterable, Identifiable {
    case snowball
    case shortcutSign = "shortcut_sign"
    case chocolateBar = "chocolate_bar"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .snowball: return "Snowball"
        case .shortcutSign: return "Fake shortcut sign"
        case .chocolateBar: return "Chocolate bar"
        }
    }

    var summary: String {
        switch self {
        case .snowball:
            return "Knocks a friend back \(Int(ItemRules.snowballKnockback)) flights."
        case .shortcutSign:
            return "The next friend behind you takes a \(Int(ItemRules.shortcutDetour))-flight detour."
        case .chocolateBar:
            return "Your flights count \(ItemRules.chocolateMultiplier.formatted())× for \(Int(ItemRules.chocolateDuration / 3600)) hours."
        }
    }

    var actionTitle: String {
        switch self {
        case .snowball: return "Throw"
        case .shortcutSign: return "Place"
        case .chocolateBar: return "Eat"
        }
    }
}

enum ItemRules {
    static let snowballKnockback: Double = 3
    static let shortcutDetour: Double = 5
    static let shortcutLifetime: TimeInterval = 48 * 3600
    static let chocolateMultiplier: Double = 1.5
    static let chocolateDuration: TimeInterval = 6 * 3600
}
