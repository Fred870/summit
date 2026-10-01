import Foundation

/// Flights climbed in one time bucket (e.g. one hour), as read from HealthKit.
struct FlightBucket: Equatable {
    let start: Date
    let flights: Double
}

/// Something that changed a climber's virtual progress in a race.
enum RaceEffect: Equatable {
    /// Hit by a snowball: slide back `flights` (never below Base Camp).
    case knockback(at: Date, flights: Double)
    /// Fell for a fake shortcut sign: the next `flights` climbed don't count.
    case detour(at: Date, flights: Double)
    /// Chocolate bar: flights climbed inside the window count `multiplier`×.
    case boost(start: Date, duration: TimeInterval, multiplier: Double)

    var date: Date {
        switch self {
        case .knockback(let at, _), .detour(let at, _): return at
        case .boost(let start, _, _): return start
        }
    }
}

/// Turns real flights plus item effects into race progress.
/// The server is the source of truth; the app runs the same rules to show progress immediately.
enum ProgressEngine {
    /// Virtual flights from Base Camp, capped at `summitFlights` when given.
    static func virtualFlights(buckets: [FlightBucket],
                               effects: [RaceEffect],
                               summitFlights: Double? = nil) -> Double {
        enum Step {
            case climb(FlightBucket)
            case effect(RaceEffect)

            var date: Date {
                switch self {
                case .climb(let b): return b.start
                case .effect(let e): return e.date
                }
            }
            /// Effects that happen at the same moment as a bucket apply first.
            var order: Int {
                switch self {
                case .effect: return 0
                case .climb: return 1
                }
            }
        }

        let boosts: [(start: Date, end: Date, multiplier: Double)] = effects.compactMap {
            if case let .boost(start, duration, multiplier) = $0 {
                return (start, start.addingTimeInterval(duration), multiplier)
            }
            return nil
        }

        let steps = (buckets.map(Step.climb) + effects.map(Step.effect))
            .sorted { ($0.date, $0.order) < ($1.date, $1.order) }

        var progress: Double = 0
        var detourLeft: Double = 0

        for step in steps {
            switch step {
            case .climb(let bucket):
                let multiplier = boosts
                    .filter { bucket.start >= $0.start && bucket.start < $0.end }
                    .map(\.multiplier)
                    .max() ?? 1
                var gained = bucket.flights * multiplier
                if detourLeft > 0 {
                    let spent = min(detourLeft, gained)
                    detourLeft -= spent
                    gained -= spent
                }
                progress += gained
            case .effect(let effect):
                switch effect {
                case .knockback(_, let flights):
                    progress = max(0, progress - flights)
                case .detour(_, let flights):
                    detourLeft += flights
                case .boost:
                    break
                }
            }
            if let cap = summitFlights {
                progress = min(progress, cap)
            }
        }
        return progress
    }
}
