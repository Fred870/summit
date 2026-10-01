import SwiftUI

struct MeView: View {
    @Environment(\.palette) private var palette

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: Spacing.s4) {
                        Circle().fill(ClimberColor.plum.color).frame(width: 64, height: 64)
                        VStack(alignment: .leading) {
                            Text("You").font(.title2.weight(.bold))
                            Text("Climber builder coming soon").font(.footnote).foregroundStyle(palette.inkMuted)
                        }
                    }
                    .padding(.vertical, Spacing.s2)
                }
                Section("Data") {
                    LabeledContent("Apple Health", value: HealthService.shared.isAvailable ? "Connected" : "Not available")
                    LabeledContent("Backend", value: Backend.client == nil ? "Not configured" : "Connected")
                }
                Section("About") {
                    LabeledContent("Version", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(palette.surface0)
            .navigationTitle("Me")
        }
    }
}
