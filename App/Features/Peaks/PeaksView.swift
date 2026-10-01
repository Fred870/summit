import SwiftUI

struct PeaksView: View {
    @Environment(\.palette) private var palette

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    peakCard(Mountain.fuji)
                    Text("More mountains are coming soon.")
                        .font(.callout)
                        .foregroundStyle(palette.inkMuted)
                }
                .padding(Spacing.s4)
            }
            .background(palette.surface0)
            .navigationTitle("Peaks")
        }
    }

    private func peakCard(_ mountain: Mountain) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s3) {
            Text(mountain.name).font(.display(30))
            Text("\(mountain.baseAltitude.formatted()) → \(mountain.summitAltitude.formatted()) m · \(mountain.totalFlights) flights")
                .font(.callout)
                .foregroundStyle(palette.inkMuted)
            ForEach(mountain.camps) { camp in
                HStack {
                    Text(camp.name).font(.headline)
                    Text(camp.station).font(.footnote).foregroundStyle(palette.inkMuted)
                    Spacer()
                    Text("\(camp.flightsFromBase) flights").font(.footnote).monospacedDigit()
                }
            }
            Button {
                // TODO: create a race (needs the backend)
            } label: {
                Text("Start a race")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(palette.action, in: Capsule())
                    .foregroundStyle(palette.onAction)
            }
            .padding(.top, Spacing.s2)
        }
        .padding(Spacing.s4)
        .background(palette.surface1, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
    }
}
