import SwiftUI
import WidgetKit

struct ClimbEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedStore.Snapshot
}

struct ClimbProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClimbEntry {
        ClimbEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (ClimbEntry) -> Void) {
        completion(ClimbEntry(date: .now, snapshot: SharedStore.load() ?? .placeholder))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClimbEntry>) -> Void) {
        let entry = ClimbEntry(date: .now, snapshot: SharedStore.load() ?? .placeholder)
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(30 * 60))))
    }
}

struct ClimbWidgetView: View {
    let entry: ClimbEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Mt. Fuji")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.75))
            Spacer()
            Text("\(entry.snapshot.altitude.formatted()) m")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .minimumScaleFactor(0.7)
            Text("#\(entry.snapshot.rank) of \(entry.snapshot.racers) · \(entry.snapshot.flightsToSummit) to go")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
        }
        .foregroundStyle(.white)
        .fontDesign(.rounded)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SummitClimbWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SummitClimb", provider: ClimbProvider()) { entry in
            ClimbWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.07, green: 0.10, blue: 0.20)
                }
        }
        .configurationDisplayName("Your climb")
        .description("Your altitude and rank in the race.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct SummitWidgetBundle: WidgetBundle {
    var body: some Widget {
        SummitClimbWidget()
    }
}
