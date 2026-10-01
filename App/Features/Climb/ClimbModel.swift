import Foundation
import Observation
import WidgetKit

@Observable
@MainActor
final class ClimbModel {
    let mountain = Mountain.fuji
    let scene: TrailScene

    var flightsToday = 0
    var myFlights: Double = 0
    var climbers: [ClimberState] = []
    var isAway = false
    var selectedClimber: ClimberState?
    var healthMessage: String?

    /// Until races come from the backend, the demo race started at the beginning of this week.
    private var raceStart: Date {
        Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
    }

    private var lastShownFlights: Double {
        get { UserDefaults.standard.double(forKey: "lastShownFlights") }
        set { UserDefaults.standard.set(newValue, forKey: "lastShownFlights") }
    }

    init() {
        scene = TrailScene(mountain: .fuji)
        let start = lastShownFlights
        myFlights = start
        climbers = DemoRace.friends + [DemoRace.me(flights: start, today: 0)]
        scene.setClimbers(climbers)
        scene.onAwayChanged = { [weak self] away in
            self?.isAway = away
        }
        scene.onClimberTapped = { [weak self] id in
            self?.selectedClimber = self?.climbers.first { $0.id == id }
        }
    }

    func refresh() async {
        let health = HealthService.shared
        guard health.isAvailable else {
            healthMessage = "Apple Health isn't available on this device."
            return
        }
        do {
            try await health.requestAccess()
            flightsToday = try await health.flightsToday()
            let buckets = try await health.hourlyBuckets(from: raceStart)
            let flights = ProgressEngine.virtualFlights(buckets: buckets, effects: [],
                                                        summitFlights: Double(mountain.totalFlights))
            apply(myFlights: flights)
            healthMessage = nil
        } catch {
            healthMessage = "Couldn't read your flights from Apple Health."
        }
    }

    func backToMe() {
        scene.returnToMe()
    }

    private func apply(myFlights newFlights: Double) {
        let previous = lastShownFlights
        myFlights = newFlights
        climbers = DemoRace.friends + [DemoRace.me(flights: newFlights, today: flightsToday)]
        scene.setClimbers(climbers)
        if newFlights != previous {
            scene.playCatchUp(from: previous, to: newFlights)
        }
        lastShownFlights = newFlights
        saveWidgetSnapshot()
    }

    var rank: Int {
        climbers.sorted { $0.flights > $1.flights }.firstIndex { $0.isMe }.map { $0 + 1 } ?? 1
    }

    private func saveWidgetSnapshot() {
        SharedStore.save(.init(altitude: mountain.altitude(atFlights: myFlights),
                               flightsToday: flightsToday,
                               rank: rank,
                               racers: climbers.count,
                               flightsToSummit: max(0, mountain.totalFlights - Int(myFlights)),
                               updated: .now))
        WidgetCenter.shared.reloadAllTimelines()
    }
}
