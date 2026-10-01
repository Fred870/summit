import Foundation

/// Mirrors the Supabase tables in supabase/migrations.
struct Profile: Codable, Identifiable, Hashable {
    let id: UUID
    var username: String
    var displayName: String
    var climberColor: ClimberColor

    enum CodingKeys: String, CodingKey {
        case id, username
        case displayName = "display_name"
        case climberColor = "climber_color"
    }
}

enum RaceStatus: String, Codable {
    case open
    case climbing
    case finalPush = "final_push"
    case finished
}

struct Race: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var mountainId: String
    var status: RaceStatus
    var startedAt: Date?
    var firstSummitAt: Date?
    var closesAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, status
        case mountainId = "mountain_id"
        case startedAt = "started_at"
        case firstSummitAt = "first_summit_at"
        case closesAt = "closes_at"
    }
}

/// One climber on the slope, as the scene and lists need it.
struct ClimberState: Identifiable, Hashable {
    let id: String
    var name: String
    var color: ClimberColor
    var flights: Double
    var flightsToday: Int
    var isMe: Bool
}

/// Local stand-in until the backend is connected.
enum DemoRace {
    static let friends: [ClimberState] = [
        ClimberState(id: "max", name: "Max", color: .glacier, flights: 196, flightsToday: 22, isMe: false),
        ClimberState(id: "lena", name: "Lena", color: .lagoon, flights: 151, flightsToday: 18, isMe: false),
        ClimberState(id: "jonas", name: "Jonas", color: .coral, flights: 98, flightsToday: 9, isMe: false),
        ClimberState(id: "mira", name: "Mira", color: .sunflower, flights: 72, flightsToday: 4, isMe: false),
        ClimberState(id: "tim", name: "Tim", color: .berry, flights: 21, flightsToday: 0, isMe: false),
    ]

    static func me(flights: Double, today: Int) -> ClimberState {
        ClimberState(id: "me", name: "You", color: .plum, flights: flights, flightsToday: today, isMe: true)
    }
}
