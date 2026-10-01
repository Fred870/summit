import SwiftUI

struct FriendsView: View {
    @Environment(\.palette) private var palette

    var body: some View {
        NavigationStack {
            List {
                Section("Race on Mt. Fuji") {
                    ForEach(Array(sortedClimbers.enumerated()), id: \.element.id) { index, climber in
                        FriendRow(rank: index + 1, climber: climber)
                    }
                }
                Section {
                    Button {
                        // TODO: invite by link, username or QR code (needs the backend)
                    } label: {
                        Label("Invite friends", systemImage: "person.badge.plus")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(palette.surface0)
            .navigationTitle("Friends")
        }
    }

    private var sortedClimbers: [ClimberState] {
        (DemoRace.friends + [DemoRace.me(flights: 120, today: 14)]).sorted { $0.flights > $1.flights }
    }
}

struct FriendRow: View {
    let rank: Int
    let climber: ClimberState
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: Spacing.s3) {
            Text("\(rank)")
                .font(.display(15))
                .foregroundStyle(palette.inkMuted)
                .frame(width: 20)
            Circle()
                .fill(climber.color.color)
                .frame(width: 36, height: 36)
                .overlay {
                    if climber.isMe {
                        Circle().stroke(palette.sun, lineWidth: 2).padding(-4)
                    }
                }
            VStack(alignment: .leading, spacing: 2) {
                Text(climber.name).font(.headline)
                Text("+\(climber.flightsToday) today · \(Mountain.fuji.camp(atFlights: climber.flights).name)")
                    .font(.footnote)
                    .foregroundStyle(palette.inkMuted)
            }
            Spacer()
            Text("\(Mountain.fuji.altitude(atFlights: climber.flights).formatted()) m")
                .font(.display(15))
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }
}
