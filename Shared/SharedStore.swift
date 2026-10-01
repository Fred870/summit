import Foundation

/// Data the app shares with the widget through the App Group.
enum SharedStore {
    static let appGroup = "group.app.summitclimb.ios"
    private static let key = "climbSnapshot"

    struct Snapshot: Codable {
        var altitude: Int
        var flightsToday: Int
        var rank: Int
        var racers: Int
        var flightsToSummit: Int
        var updated: Date

        static let placeholder = Snapshot(altitude: 2_700, flightsToday: 14, rank: 2, racers: 6,
                                          flightsToSummit: 360, updated: .now)
    }

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? .standard
    }

    static func save(_ snapshot: Snapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
    }

    static func load() -> Snapshot? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }
}
