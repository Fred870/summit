import SwiftUI

@main
struct SummitApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Tabs: Climb · Friends · Peaks · Me. The UI theme follows the sky (Day/Night).
struct RootView: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let theme = SkyTheme.at(context.date)
            TabView {
                Tab("Climb", systemImage: "mountain.2.fill") { ClimbView() }
                Tab("Friends", systemImage: "person.2.fill") { FriendsView() }
                Tab("Peaks", systemImage: "flag.fill") { PeaksView() }
                Tab("Me", systemImage: "person.crop.circle.fill") { MeView() }
            }
            .tint(theme.palette.ink)
            .fontDesign(.rounded)
            .environment(\.palette, theme.palette)
            .preferredColorScheme(theme.colorScheme)
        }
    }
}
