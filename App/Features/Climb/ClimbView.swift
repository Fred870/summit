import SpriteKit
import SwiftUI

/// Trail Cam: the scene with the header, "Back to you" and the zoom-out mountain button over it.
struct ClimbView: View {
    @State private var model = ClimbModel()
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            SpriteView(scene: model.scene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: Spacing.s1) {
                header
                Spacer()
                bottomControls
            }
            .padding(.horizontal, Spacing.s4)
            .padding(.bottom, Spacing.s3)
        }
        .task { await model.refresh() }
        .sheet(item: $model.selectedClimber) { climber in
            ClimberCard(climber: climber, myFlights: model.myFlights)
                .presentationDetents([.height(260)])
                .presentationCornerRadius(Radius.xl)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("\(model.mountain.name) · Day \(dayOfRace)")
                    .font(.footnote.weight(.semibold))
                Spacer()
                Text(model.mountain.camp(atFlights: model.myFlights).name)
                    .font(.footnote.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            Text("\(model.flightsToday)")
                .font(.display(84))
                .monospacedDigit()
                .contentTransition(.numericText())
            Text("flights today")
                .font(.headline)
            if let message = model.healthMessage {
                Text(message)
                    .font(.footnote)
                    .padding(.top, Spacing.s2)
            }
        }
        .foregroundStyle(Color(hex: 0x2B1D04))
        .padding(.top, Spacing.s2)
    }

    private var bottomControls: some View {
        HStack(alignment: .bottom) {
            Spacer()
            if model.isAway {
                Button {
                    model.backToMe()
                } label: {
                    Label("Back to you", systemImage: "scope")
                        .font(.callout.weight(.semibold))
                        .padding(.horizontal, Spacing.s4)
                        .frame(minHeight: 44)
                        .background(palette.action, in: Capsule())
                        .foregroundStyle(palette.onAction)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer()
            ZoomOutButton()
        }
        .animation(.spring(duration: 0.35), value: model.isAway)
    }

    private var dayOfRace: Int {
        let start = Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return (Calendar.current.dateComponents([.day], from: start, to: .now).day ?? 0) + 1
    }
}

/// Mountain-shaped button that opens the Ridge overview (not built yet).
struct ZoomOutButton: View {
    @Environment(\.palette) private var palette

    var body: some View {
        Button {
            // TODO: open Ridge (zoomed-out view)
        } label: {
            ZStack {
                MountainShape().fill(Color(hex: 0x121A28))
                Image(systemName: "minus.magnifyingglass")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(y: 10)
            }
            .frame(width: 80, height: 56)
            .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
        }
        .accessibilityLabel("Zoom out to the whole mountain")
    }
}

struct MountainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: 0, y: h))
        path.addQuadCurve(to: CGPoint(x: w * 0.44, y: h * 0.12), control: CGPoint(x: w * 0.38, y: h * 0.92))
        path.addLine(to: CGPoint(x: w * 0.56, y: h * 0.12))
        path.addQuadCurve(to: CGPoint(x: w, y: h), control: CGPoint(x: w * 0.62, y: h * 0.92))
        path.closeSubpath()
        return path
    }
}

/// Card for a tapped climber: altitude, today's flights, Nudge.
struct ClimberCard: View {
    let climber: ClimberState
    let myFlights: Double
    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s4) {
            HStack(spacing: Spacing.s3) {
                Circle().fill(climber.color.color).frame(width: 44, height: 44)
                VStack(alignment: .leading) {
                    Text(climber.name).font(.title3.weight(.bold))
                    Text(distanceText).font(.callout).foregroundStyle(palette.inkMuted)
                }
            }
            HStack(spacing: Spacing.s3) {
                stat(Mountain.fuji.altitude(atFlights: climber.flights).formatted() + " m", "Altitude")
                stat("\(climber.flightsToday)", "Flights today")
            }
            Button {
                dismiss()
            } label: {
                Text("Nudge \(climber.name)")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(palette.surface2, in: Capsule())
                    .foregroundStyle(palette.ink)
            }
        }
        .padding(Spacing.s4)
    }

    private var distanceText: String {
        let meters = Int(((climber.flights - myFlights) * Mountain.metersPerFlight).rounded())
        return meters >= 0 ? "\(meters.formatted()) m ahead of you" : "\(abs(meters).formatted()) m behind you"
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.display(22)).monospacedDigit()
            Text(label).font(.footnote).foregroundStyle(palette.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.s3)
        .background(palette.surface2, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
    }
}
