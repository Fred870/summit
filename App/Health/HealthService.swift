import Foundation
import HealthKit

/// Reads Flights Climbed from Apple Health.
/// Rules (research/market-and-data-deepdive.md): ignore user-entered samples; v1 counts iPhone and Apple Watch only.
final class HealthService {
    static let shared = HealthService()

    private let store = HKHealthStore()
    private let flightsType = HKQuantityType(.flightsClimbed)

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAccess() async throws {
        guard isAvailable else { return }
        try await store.requestAuthorization(toShare: [], read: [flightsType])
    }

    /// Total flights between two dates, de-duplicated across sources by HealthKit.
    func flights(from start: Date, to end: Date = .now) async throws -> Int {
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: flightsType, predicate: predicate(from: start, to: end)),
            options: .cumulativeSum)
        let statistics = try await descriptor.result(for: store)
        return Int(statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
    }

    func flightsToday() async throws -> Int {
        try await flights(from: Calendar.current.startOfDay(for: .now))
    }

    /// Hourly buckets since a date, for the race progress engine.
    func hourlyBuckets(from start: Date, to end: Date = .now) async throws -> [FlightBucket] {
        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: .quantitySample(type: flightsType, predicate: predicate(from: start, to: end)),
            options: .cumulativeSum,
            anchorDate: Calendar.current.startOfDay(for: start),
            intervalComponents: DateComponents(hour: 1))
        let collection = try await descriptor.result(for: store)
        var buckets: [FlightBucket] = []
        collection.enumerateStatistics(from: start, to: end) { statistics, _ in
            let flights = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
            if flights > 0 {
                buckets.append(FlightBucket(start: statistics.startDate, flights: flights))
            }
        }
        return buckets
    }

    private func predicate(from start: Date, to end: Date) -> NSPredicate {
        let window = HKQuery.predicateForSamples(withStart: start, end: end)
        let userEntered = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyWasUserEntered,
                                                      allowedValues: [true])
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            window,
            NSCompoundPredicate(notPredicateWithSubpredicate: userEntered),
        ])
    }
}
