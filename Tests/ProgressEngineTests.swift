import XCTest
@testable import Summit

final class ProgressEngineTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_790_000_000)
    private func at(_ hours: Double) -> Date { t0.addingTimeInterval(hours * 3600) }

    func testPlainFlightsAddUp() {
        let buckets = [FlightBucket(start: at(0), flights: 10), FlightBucket(start: at(1), flights: 5)]
        XCTAssertEqual(ProgressEngine.virtualFlights(buckets: buckets, effects: []), 15)
    }

    func testSnowballKnocksBackButNotBelowBaseCamp() {
        let buckets = [FlightBucket(start: at(0), flights: 2)]
        let effects: [RaceEffect] = [.knockback(at: at(1), flights: ItemRules.snowballKnockback)]
        XCTAssertEqual(ProgressEngine.virtualFlights(buckets: buckets, effects: effects), 0)
    }

    func testDetourSwallowsTheNextFlights() {
        let buckets = [FlightBucket(start: at(0), flights: 10), FlightBucket(start: at(2), flights: 8)]
        let effects: [RaceEffect] = [.detour(at: at(1), flights: ItemRules.shortcutDetour)]
        XCTAssertEqual(ProgressEngine.virtualFlights(buckets: buckets, effects: effects), 13)
    }

    func testChocolateBoostsOnlyInsideTheWindow() {
        let buckets = [
            FlightBucket(start: at(0), flights: 10),  // inside: 15
            FlightBucket(start: at(5), flights: 10),  // inside: 15
            FlightBucket(start: at(7), flights: 10),  // outside: 10
        ]
        let effects: [RaceEffect] = [.boost(start: at(0), duration: ItemRules.chocolateDuration,
                                            multiplier: ItemRules.chocolateMultiplier)]
        XCTAssertEqual(ProgressEngine.virtualFlights(buckets: buckets, effects: effects), 40)
    }

    func testProgressStopsAtTheSummit() {
        let buckets = [FlightBucket(start: at(0), flights: 600)]
        XCTAssertEqual(ProgressEngine.virtualFlights(buckets: buckets, effects: [],
                                                     summitFlights: Double(Mountain.fuji.totalFlights)), 490)
    }

    func testFujiNumbers() {
        XCTAssertEqual(Mountain.fuji.totalFlights, 490)
        XCTAssertEqual(Mountain.fuji.altitude(atFlights: 0), 2305)
        XCTAssertEqual(Mountain.fuji.altitude(atFlights: 490), 3776)
        XCTAssertEqual(Mountain.fuji.camp(atFlights: 140).name, "Camp 2")
    }
}
