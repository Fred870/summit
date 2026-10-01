import Foundation

/// A checkpoint on the route. Same naming on every mountain: Base Camp → Camp 1…4 → Summit.
struct Camp: Identifiable, Hashable {
    let id: Int
    let name: String
    /// The real-world place it stands for (e.g. "7th Station").
    let station: String
    let altitude: Int
    let flightsFromBase: Int
}

struct Mountain: Identifiable {
    /// 1 flight of stairs ≈ 3 m of elevation (Apple Health "Flights Climbed").
    static let metersPerFlight: Double = 3

    let id: String
    let name: String
    let baseAltitude: Int
    let summitAltitude: Int
    let camps: [Camp]

    /// Flights from Base Camp to the summit.
    var totalFlights: Int {
        Int((Double(summitAltitude - baseAltitude) / Mountain.metersPerFlight).rounded())
    }

    func altitude(atFlights flights: Double) -> Int {
        let clamped = min(max(flights, 0), Double(totalFlights))
        if clamped >= Double(totalFlights) { return summitAltitude }
        return baseAltitude + Int((clamped * Mountain.metersPerFlight).rounded())
    }

    /// The last camp reached at this many flights.
    func camp(atFlights flights: Double) -> Camp {
        camps.last(where: { Double($0.flightsFromBase) <= flights }) ?? camps[0]
    }

    func nextCamp(afterFlights flights: Double) -> Camp? {
        camps.first(where: { Double($0.flightsFromBase) > flights })
    }

    /// Mt. Fuji, Yoshida trail. Base Camp at the Fuji Subaru Line 5th Station.
    /// Heights follow the real stations and still need verifying (see product/slc-scope.md).
    static let fuji = Mountain(
        id: "fuji",
        name: "Mt. Fuji",
        baseAltitude: 2305,
        summitAltitude: 3776,
        camps: [
            Camp(id: 0, name: "Base Camp", station: "5th Station", altitude: 2305, flightsFromBase: 0),
            Camp(id: 1, name: "Camp 1", station: "6th Station", altitude: 2390, flightsFromBase: 28),
            Camp(id: 2, name: "Camp 2", station: "7th Station", altitude: 2700, flightsFromBase: 130),
            Camp(id: 3, name: "Camp 3", station: "8th Station", altitude: 3100, flightsFromBase: 265),
            Camp(id: 4, name: "Camp 4", station: "9th Station", altitude: 3600, flightsFromBase: 430),
            Camp(id: 5, name: "Summit", station: "Crater rim", altitude: 3776, flightsFromBase: 490),
        ])
}
