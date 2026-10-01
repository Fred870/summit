# Summit – SLC Scope (v1)

Living scope doc. SLC = Simple, Lovable, Complete ([asmartbear](https://longform.asmartbear.com/slc/)): a small product that does one thing completely and that people love, before we add a lot of features.
Related: `research/market-and-data-deepdive.md`, `design/design.md`.

## One-liner
Race your friends up a real mountain using the stairs you climb in real life, and throw things at them on the way.

## Decisions (30 Sep 2026)
- **Focus:** friends and competition come first. Every feature has to make a race against people you know more fun.
- **Game loop:** race to the summit. A group picks a mountain, and the first person to the top wins.
- **Race end:** the race runs with no time limit until the first climber reaches the summit. Everyone else then gets **3 days to catch up**. When those 3 days are over, the race closes and the others are ranked by altitude.
- **Mountains:** real heights with no scaling. **The SLC ships with one mountain: Mt. Fuji.** Races start at base camp, not sea level. More mountains come later.
- **Checkpoints are camps:** Base Camp → Camp 1…4 → Summit, the same naming on every mountain.
- **Friends:** a persistent friend list, and races are started from that list. No public matchmaking.
- **Items:** found along the route. Climbing more means finding more items.
- **Gear:** cosmetic **plus small gameplay effects**.
- **Must-haves in the SLC:** push notifications for sabotage and overtakes, a home-screen widget, and a summit celebration with a shareable card.
- **Monetization:** free, with no in-app purchases in the SLC.
- **Data:** Apple Health Flights Climbed only, from iPhone and Apple Watch (see research doc).
- **Visual style:** to be defined later. Trail Cam and Ridge from `design.md` are the working basis, and the bar is "insanely beautiful".

## The mountain: Mt. Fuji
- **Base Camp** sits at the Fuji Subaru Line 5th Station (~2,305 m). **Summit** is 3,776 m.
- The climb is **~1,471 m ≈ 490 flights** (1 flight ≈ 3 m).
- Camps are checkpoints and item spots (heights approximate; they follow Fuji's real stations and need verifying):

| Camp | Altitude | Flights from Base Camp |
|---|---|---|
| Base Camp (5th Station) | ~2,305 m | 0 |
| Camp 1 (6th Station) | ~2,390 m | ~28 |
| Camp 2 (7th Station) | ~2,700 m | ~130 |
| Camp 3 (8th Station) | ~3,100 m | ~265 |
| Camp 4 (9th Station) | ~3,600 m | ~430 |
| Summit | 3,776 m | ~490 |

- Real-station gaps are uneven (Camp 1 comes very early). We may even out the camp heights for game feel; see open questions.
- Pace check: the winner decides the length. A climber doing 30 flights a day finishes in ~16 days, 20 a day in ~25 days, and 10 a day in ~49 days.
- ⚠️ `design.md` mockups still use a sea-level start (1,259 flights, "Day X of 30", "5th Station" milestone). They need to be updated to Base Camp → Summit, camps, and no fixed day count.

## Core loop
1. Create a race: pick friends from your list, and the mountain is Fuji.
2. Everyone starts at Base Camp. Only flights climbed after the race starts count.
3. Climb stairs in real life. The app syncs from HealthKit and your climber moves up the slope.
4. Find items at camps and every N flights. Throw them at friends, place them on the route, or keep them for defence.
5. Get pushes when someone overtakes you, hits you, or reaches a camp.
6. The first climber to the summit wins. That triggers the summit celebration for them and a **3-day catch-up window** for everyone else.
7. During the window, others can still summit to earn a placing. After 3 days the race closes and the final ranking goes out: summit order first, then everyone else by altitude.

## Race states
| State | What happens |
|---|---|
| Open | Friends accept the invite. The race starts when the creator taps Start (or when everyone has accepted). |
| Climbing | No time limit. The header shows the race day ("Day 12") and the leader's distance to the summit. |
| Final push | The first climber has summited. A 3-day countdown runs, and pushes go out ("Lena summited! You have 3 days"). |
| Finished | The race locks and the final ranking and share card are shown. |

## Climber (avatar)
- Simple builder at onboarding: body shape, skin tone, hair, face, and jacket colour. It should be quick and charming, not a character-creator rabbit hole.
- The climber replaces the initial circles in Trail Cam and Ridge, so friends see *your* climber on the slope.
- Gear appears on the climber visibly, so you can see a friend's crampons and helmet.

## Gear (cosmetic + small effects)
Proposal: gear unlocks at **lifetime altitude milestones** (since there are no coins or IAP). You equip up to one item per slot.

| Slot | Example | Effect (small) |
|---|---|---|
| Head | Helmet | Blocks the first Boulder that hits you in each race |
| Feet | Crampons | Immune to Ice Patch |
| Back | Big backpack | Hold 2 items instead of 1 |
| Hands | Trekking poles | Slightly higher item-drop chance |
| Style | Jackets, hats, flags | Cosmetic only |

Balancing rule: an effect can never be worth more than a few flights. Real climbing always wins.

## Items (found along the route)
Rules: items affect **virtual** progress only, never your Health data. The server resolves them so they're fair and can't be cheated. You can hold 1 item (2 with a backpack). All numbers are starting values to tune in playtests.

**Core items (1 Oct 2026, Caius):**

| Item | Type | Effect | Starting value |
|---|---|---|---|
| Snowball | Attack (thrown) | Hits another player, who **falls back X flights** | X = 3 flights (~9 m) |
| Fake shortcut sign | Trap (placed) | You place a fake "Shortcut →" sign at your spot on the route. The **next player who reaches it** takes the "shortcut" and has to **walk X extra flights** (a detour) before their progress counts again | X = 5 flights |
| Chocolate bar | Boost (self) | All flights you climb count **1.5×** for **6 hours** after eating it | 1.5× for 6 h |

- Snowball animation: the snowball flies in, the target is hit, tumbles back down the slope and dusts off the snow.
- Shortcut sign: it is visible on the slope as a wooden sign. When a friend falls for it, they walk off on a side path and come back. You get a push ("Jonas fell for your shortcut 😏") and they get one ("That was no shortcut… +5 flights detour"). A sign only catches climbers who are behind you, catches one person, then disappears. It expires after 48 h if nobody reaches it.
- Chocolate bar: the climber eats it, and a small "1.5×" badge with a 6 h countdown and a glow shows while it's active. Flights count by the time they were climbed (sample timestamp), so stairs climbed inside the 6 h window get the boost even if they sync later.

**Earlier ideas (keep or cut after playtests):**

| Item | Type | Effect |
|---|---|---|
| Boulder | Attack (rarer) | Target slides back ~10 flights |
| Ice Patch | Attack | Target's next 5 flights count half |
| Fog | Tactic | Target can't see the leaderboard for 12 h |

Drop chance can lean slightly toward whoever is behind. Keep that subtle.

## Friends & social
- Friend list: add by username, invite link, or QR code. Sign in with Apple.
- Races: 2–8 people, started from the friend list. You can join multiple races, since everyone's flights count in every race they're in.
- Pushes: "Lena hit you with a Snowball (−3 flights)", "Jonas fell for your shortcut", "Max overtook you", "Jonas reached Camp 3", "3 flights to the summit!", "Lena summited, you have 3 days to catch up", and "12 h left in the final push".
- Nudge button (already in `design.md`) for friends who have gone quiet.

## Widget
- Small: your altitude, your rank, and flights to the summit. During the final push it shows the countdown.
- Medium: mini slope showing you and the friends right next to you.

## Summit moment
- A full-screen celebration when you reach the top (flag, sunrise over the crater, confetti snow).
- A share card sized for Instagram Stories: climber at the summit, days taken, flights, and final rank.

## Screens in the SLC
- Onboarding: Health permission, climber builder, then add friends.
- **Climb:** Trail Cam, zooming out to Ridge (per `design.md`), plus item slot and throw/place action.
- **Friends:** friend list, invites, and pending requests.
- **Peaks:** Fuji only for now (other mountains shown as "coming soon"), and create race.
- **Me:** climber and gear, lifetime altitude, and past races.

## Tech notes
- HealthKit `flightsClimbed` with a cumulative-sum statistics query. Ignore user-entered samples, and accept only iPhone and Apple Watch sources.
- Background delivery is best-effort, so sync on app open, from the widget, and on push. Needs a clear rule for when a flight "counts" in a race, most importantly for who summited first and for the end of the 3-day window. Proposal: flights count by the time they were climbed (the sample timestamp), not by sync time, with a short grace period after the window closes for late syncs.
- A backend is required for the friend graph, races, item resolution (including where shortcut signs sit and who triggers them), race-state timers, and push (APNs). Choose one (Supabase, Firebase, or CloudKit plus a server).

## Not in the SLC (later)
More mountains, gym data (StairMaster/treadmill), Apple Watch app, public races, IAP and monetization, chat, Android, co-op expeditions, and seasons or leagues.

## Open questions
- Camp heights: follow Fuji's real stations, or even them out (e.g. about every 100 flights)?
- Items in the final push: can the others still throw at each other, and can anyone throw at a climber who has already summited? (Proposal: summited climbers are safe, and the rest keep playing.)
- How is gear unlocked: lifetime altitude (proposed), race placements, or finding it on the route?
- Final values for Snowball (X flights), Shortcut sign (X flights detour) and Chocolate bar (1.5× for 6 h, check against the balancing rule: 30 flights in that window = +15); and whether Boulder, Ice Patch and Fog stay.
- Shortcut sign: can you place it anywhere, or not right in front of a camp? Can several signs stack on the same stretch?
- Can you throw at anyone in the race, or only the person just ahead or behind?
- Visual style, brand, and app icon (see `design.md`).
