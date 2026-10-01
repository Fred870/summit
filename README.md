# Summit

Race your friends up a real mountain using the stairs you climb in real life. iOS app (SwiftUI + SpriteKit), Supabase backend.

- Product scope: `slc-scope.md` · Design: `design.md` · UI system: `design-system.md`
- Bundle ID `app.summitclimb.ios`, iOS 18+, iPhone only, English.

## First run (on your Mac)

1. Install the tools once:
   ```sh
   brew install xcodegen
   ```
2. Copy the personal settings file and add your Team ID (Xcode › Settings › Accounts › your Apple ID):
   ```sh
   cp Config/Local.example.xcconfig Config/Local.xcconfig
   ```
   Supabase values can stay empty for now; the app then runs with demo friends.
3. Generate the Xcode project and open it:
   ```sh
   xcodegen
   open Summit.xcodeproj
   ```
4. Pick your iPhone as the run destination and press Run. The first time, allow "Developer Mode" on the phone and trust your developer certificate (Settings › General › VPN & Device Management).

Run `xcodegen` again whenever files are added or `project.yml` changes. The `.xcodeproj` is generated and not committed.

### Free Apple account notes
- Apps signed with a free account stop launching after 7 days; just run again from Xcode.
- Push notifications, Sign in with Apple and TestFlight need the paid Apple Developer Program. Until then, sign-in will use Supabase email codes.
- If signing fails on **App Groups**, remove the two `com.apple.security.application-groups` lines in `project.yml` and run `xcodegen` again (the widget then shows placeholder data).

## Structure

| Folder | What |
|---|---|
| `App/Design` | Design tokens (colours, type, radii) from the Summit Design System |
| `App/Game` | Mountain data, items, progress engine (pure Swift, unit-tested) |
| `App/Health` | HealthKit: Flights Climbed, user-entered samples excluded |
| `App/Scene` | SpriteKit Trail Cam: trail path, camera, 7 parallax layers, drag-to-scroll, tilt, catch-up |
| `App/Features` | Climb, Friends, Peaks, Me screens |
| `App/Backend` | Supabase client (reads `Config/Local.xcconfig`) |
| `Shared` | Code shared by app and widget (App Group store) |
| `Widget` | Home-screen widget |
| `Tests` | Unit tests (`⌘U`) |
| `supabase/migrations` | Database schema and row-level security |

## Road to V1 (SLC)

1. **Foundation** – project, design tokens, HealthKit reading, Trail Cam scene with parallax and scrolling, demo race. ✅ this commit
2. **Accounts & friends** – Supabase project, email-code sign-in, profiles, add friends by username / link.
3. **Races** – create race on Fuji, invite, start; upload hourly flight buckets; server computes progress; race states (climbing → final push → finished, 3-day window).
4. **Items** – drops at camps and every N flights; Snowball, Fake shortcut sign, Chocolate bar resolved on the server; events timeline.
5. **Catch-up replay & moments** – replay events on open; camp reached, hit, detour, boost, overtake animations; summit celebration + share card.
6. **Art pass** – real layer assets for all 5 zones, Noodle climber rig, time-of-day and weather.
7. **Ridge view, widget, notifications** – zoomed-out view; widget with live data; push (needs paid account).
8. **TestFlight** – paid account, Sign in with Apple, privacy labels, beta with friends.
