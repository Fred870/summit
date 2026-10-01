# Summit – Design

Living design spec. More sections to be defined later.

Canvas with all explored concepts: https://claude.ai/artifact/8RpHvtgp7wHXvaTbVraMQs (example mountain: Mt. Fuji, 3,776 m)

## Decisions
- 30 Sep 2026: **Home screen = "Trail Cam" (concept 5) as the default view**, with **"Ridge" (concept 1) as the zoomed-out view** of the same race.
- Concepts 2 (Night Altimeter), 3 (Stamp Book) and 4 (Topo Map) are not chosen for now. They stay on the canvas as reference.
- Direction: similar game loop to Stompers, but cleaner. No cartoon clutter, no shop on the home screen.
- 30 Sep 2026: **Scene style = soft 2D layered, no outlines** (the 5.x "Trail Cam scenes" row on the canvas is the favourite set). The layers are: stepped sky bands, sun or moon, far ridges, middle hills, and the front slope with a light edge along the ridge. The small details are rounded clouds, rocks, pines and trail posts with flags.
- 30 Sep 2026: **Live weather and time of day** change the scene. The explored options are dawn, clear noon, golden hour, night, snowfall and misty rain (more on the canvas: sea of clouds, thunderstorm, windy, heatwave, overcast, rainbow).
- 30 Sep 2026: **No summit in the background of Trail Cam.** A **mountain-shaped zoom-out button** (with a snow cap and a magnifying glass) sits at the bottom right above the tab bar and opens the Ridge overview.
- 1 Oct 2026: **Character direction = "Noodle"** (see the Character section).
- 1 Oct 2026: **Scene & animation approach agreed, including the catch-up climb** (see the Scene & animation section).
- 1 Oct 2026: **Trail Cam can be scrolled a little along the slope** to peek at climbers out of view, and the scene gets a **stronger parallax** (see Scene & animation → Scrolling the slope, Parallax).

## Home screen – main view: Trail Cam (zoomed in)
A close-up of the slope, centred on you. It feels like a game and is about who is right next to you.
- **Header:** mountain name and race day ("Mt. Fuji · Day 12 of 30"), sync status chip, a big count of today's flights, and meters gained today ("+42 m").
- **Scene:** a diagonal slope across the screen in the layered style, changing with the live weather and time of day. The summit is not shown in the background.
- **Zoom-out button:** mountain-shaped, at the bottom right above the tab bar, and opens Ridge.
  - **You:** a large avatar in the centre with a dark label ("You · 1,990 m", "2nd of 5").
  - **Friend just ahead:** a smaller avatar further up the slope with a distance label ("Lena · 622 m ahead").
  - **Friend just behind:** a smaller avatar further down the slope with a distance label and a **Nudge** button ("Jonas · 518 m behind").
  - At rest only these two neighbours are in view. Drag along the slope to peek further up or down (see Scrolling the slope).
- **Progress track (card above the tab bar):** a line from base to summit with a milestone tick (e.g. 5th Station), every friend as a small dot, and you as a larger dot on a filled progress bar.
- **Tab bar:** Climb · Friends · Peaks · Me.

## Home screen – zoomed-out view: Ridge
The whole mountain from the side, for an overview of the full race.
- **Header:** mountain name and height, "Day X of 30" chip, today's flights, and "+m today · N flights to the summit".
- **Mountain:** side view with a snow cap and a dashed switchback trail. All friends are avatars on the trail at their altitude, and you are highlighted with a halo and a "You · 1,990 m" label.
- **Leaderboard card:** rank, avatar, name, "+N today", altitude. Your row is bold.

## Switching between views
- The mountain-shaped button at the bottom right zooms out to Ridge. Still to define: the transition animation, how to zoom back in, and whether pinching also works.

## Character (in progress)
- 1 Oct 2026: **Direction = "Noodle"**, based on Caius' ChatGPT reference. It's a plain, single-colour figure: a round head, a thin neck and a slim torso. Its limbs are long, soft and tapered, with thick thighs, big oval paddle hands and chunky flat-bottomed boots. The face is two small vertical oval eyes and a small smile. It has no outlines and no texture, only soft shading.
- Each friend is one body colour (blue, teal, purple, pink, orange). No equipment on the base character; gear comes later as separate items.
- The canvas board "9.1 · Noodle · character sheet" has the walking pose, a front / 3/4 / back turnaround, expressions (happy, determined, cheering, surprised by a snowball), colour variants and the character in a scene.
- The figure is built from a joint skeleton (shoulder, elbow, hand, hip, knee, foot), so poses map directly onto a Rive or Spine rig.
- Earlier explorations stay on the canvas as reference: Parka / Hiker / Goat (7.x) and Bean / Marmot / Pebble (8.x).
- Pipeline idea: final art can come from image generation plus an illustrator pass, cut into parts and then rigged in Rive. Avoid frame-by-frame AI animation, because the details shift between frames.

## Scene & animation (1 Oct 2026)
The Trail Cam scene works like a small 2D game world with a camera that follows your climber. Two inputs drive it separately: **your altitude** decides the ground and scenery, and **real time of day plus weather** decides the sky and light.

### Scenery changes with altitude (Fuji zones; camps are the borders)
| Zone | Range | Look |
|---|---|---|
| Forest edge | Base Camp → Camp 1 | Larch and pine, grass tufts, wooden trail posts, start gate |
| Red scree | Camp 1 → Camp 2 | Red-brown volcanic ground, switchbacks, rope fences, first huts |
| Hut belt | Camp 2 → Camp 3 | Rocky, many mountain huts (like Fuji's real 7th–8th stations) |
| High and cold | Camp 3 → Camp 4 | Grey stone, snow patches, wind flags, fewer props |
| Crater rim | Camp 4 → Summit | Stone steps, summit marker, crater edge, flag |
- The slope is built from segments of about 10 flights each, generated as you climb.
- Camp huts, sign boards and the summit marker are fixed landmarks.
- Filler props (rocks, shrubs, posts) are placed randomly, but seeded by race and segment, so everyone in a race sees the same mountain.
- Ground colours blend gradually by altitude, with no hard cuts between zones.

### Three kinds of animation
1. **Background loop, always on:** clouds drift with depth, pines sway, flags flutter, hut chimneys smoke, weather particles fall, the sun and moon follow real time, and the climber idles.
2. **Catch-up climb (decided: included):** when new flights sync, the climber doesn't jump. They walk up for 2–4 s while the camera follows, the layers scroll at different speeds, and the flight count ticks up. Passing a camp brings the hut into view and plays the "Camp reached" moment. A long sync is sped up so it never takes more than ~4 s.
   - **The catch-up is a replay** of everything that happened since you last opened the app, in time order, along the climb (spec below).
3. **Event moments:** overtaking or being overtaken, getting hit by a Snowball, falling for a Fake shortcut sign, eating a Chocolate bar, finding an item, reaching a camp, and the summit celebration.

### Catch-up replay (1 Oct 2026)
On app open, the climber walks from where you last saw them to where they are now. On the way, everything that happened in between plays at the altitude where it happened.
- **Data:** the server sends a timeline of events since your last view (time, altitude, type, who). The climb is split at those points, and each event plays its animation, then the walk continues.
- **Length:** ~1–1.5 s per event, total capped at ~8 s. With more than ~4 events, the most important ones are animated and the rest appear as chips at the end ("+2 more"). Tap to speed up, or skip to the end.
- **Priority:** hits on you > shortcut detours > overtakes > camps reached > your own item successes > items found.
- **The counter is honest:** the flight count ticks up while walking, down on a hit, pauses on a detour, and shows "1.5×" while a boost was active.
- **Pushes:** tapping a push opens the app and starts the replay at that event.

| Event | Animation in the replay | Chip |
|---|---|---|
| Hit by a Snowball | Snowball arcs in from the thrower's side, splat, the climber tumbles and slides back down the slope, sits up and shakes off the snow | "−3 flights · Lena's snowball" |
| Your Snowball hit someone | Small bubble cut-in of the friend getting hit | "You hit Jonas · −3" |
| Fell for a Fake shortcut sign | The climber reaches the sign, takes the side path, walks a loop out of view and comes back confused ("?"); the counter pauses during the detour | "+5 flights detour · Lena's sign" |
| Someone fell for your sign | Bubble cut-in: the friend walks off on the side path; your sign falls over | "Jonas fell for it" |
| Ate a Chocolate bar | The climber unwraps it and takes three bites, then a glow turns on; steps sparkle and the counter ticks in accent colour during the boosted stretch; the glow fades where the 6 h ended | "1.5× for 6 h" |
| Overtake | The other climber walks past you (or you past them), with a small whoosh | "Max overtook you" / "You passed Mira" |
| Camp reached | The hut slides in, a flag goes up, a camp stamp lands | "Camp 2 · 2,700 m" |
| Item found | A sparkle at the spot, then the item pops into your slot | "Found: Snowball" |
- After the replay, the scene settles into the background loop, with any active boost or held item still visible.
- Each item also needs a short **live** version (when you throw or place it yourself while the app is open), reusing the same animation parts.

### Scrolling the slope (1 Oct 2026)
You can drag the scene a short way up or down the slope to see climbers who are just out of view.
- **Gesture:** a horizontal or diagonal drag moves the camera along the trail (not freely). Vertical drags stay free for the app's own scrolling.
- **Range:** about one screen up and one screen down the slope (roughly ±40 flights, final value to tune). At the limit the scene rubber-bands like an iOS scroll view.
- **Return:** on release the camera springs back to your climber after ~2 s, or right away when you tap your climber or the "back to you" chip that appears while you're scrolled away.
- **Labels:** climbers come into view with their name and distance ("Lena · 622 m ahead"). Tapping a climber opens a small card (altitude, today's flights, Nudge, throw an item at them if you hold one).
- **Further away:** players outside the scroll range show as small edge markers (climber dot, name, distance and an arrow) pinned to the top or bottom edge. Tapping one jumps to Ridge with that player highlighted.
- **Feel:** light haptic tick when a climber or camp sign enters view; the header chips stay put while the scene moves.
- **Not during the replay:** scrolling is locked while the catch-up replay runs; a drag skips the replay to the end.

### Parallax (1 Oct 2026)
Every layer moves at its own speed when the camera moves (climbing, replay, scrolling). Stronger spread between layers = more depth.

| Layer | Speed vs. camera | Notes |
|---|---|---|
| Sky bands, sun/moon, stars | 0 (fixed) | Only change with time of day |
| High clouds | 0.05 | Plus their own slow drift |
| Far ridges | 0.15 | Lightest, most hazy colour |
| Middle ridges | 0.35 | |
| Near hills / tree line | 0.6 | |
| Slope, trail, props, climbers | 1.0 | The "camera layer" |
| Foreground (grass tufts, rocks, branches at the screen edges) | 1.4 | Passes in front of the climbers; slightly blurred and darker |
- **More layers:** add a near-hills layer and a foreground layer to the five existing ones, so there are 6–7 planes.
- **Depth cues:** further layers are lighter, bluer and less saturated (atmospheric haze, stronger in fog and snow), and slightly smaller in detail.
- **Device tilt:** a subtle gyroscope parallax (a few points of shift per layer, like the iOS home screen) so the scene feels alive even when nothing moves. Off with Reduce Motion.
- **Vertical too:** the slope is diagonal, so layers shift on both axes; far layers shift less vertically than horizontally to keep the horizon calm.

### Time of day & weather
- Every prop is drawn once in neutral daylight. Time of day is a colour tint over all layers, plus extras such as lit hut windows, stars and the sun or moon position.
- Weather = particles (snow, rain, fog, wind, lightning) plus a sky palette (from the 5.x/6.x boards).

### Tech
- Scene: **SpriteKit** inside SwiftUI (camera, depth layers, particle editor).
- Character: **Rive** rig (walk, idle, cheer, hit, eat), or joint animation in code as the simpler fallback.
- Battery: cap the background loop at 30 fps, pause everything when the app is off-screen, and use a still image for the widget.

### Asset list (first pass)
- **Sky:** colour bands per time of day (values only), sun, moon, stars, 4–6 cloud shapes.
- **Background:** 3–4 distant ridge shapes that repeat sideways, plus a middle ridge and a near-hills/tree-line layer.
- **Foreground:** grass tufts, rocks and branch silhouettes for the 1.4× layer at the screen edges.
- **Ground:** a repeating slope piece and a ridge-edge strip per zone.
- **Props:** pines, larches, shrubs, grass, start gate; rocks (~6 sizes), boulders, rope fences, stone steps; 3 mountain hut variants (night windows, chimney smoke, flags), camp sign boards Camp 1–4; snow patches, icy rocks; summit marker, crater rim, flag pole.
- **Effects:** snow, rain, fog strips, wind streaks, lightning, dust puffs from footsteps, item sparkles.
- **Items:**
  - Snowball: held, in flight, impact splat, and the target tumbling back.
  - Fake shortcut sign: a wooden "Shortcut →" sign, plus a side-path detour for whoever falls for it.
  - Chocolate bar: in hand, the climber eating it, and a "1.5×" badge with a 6 h countdown and a glow while it's active.
- **Character:** the Noodle rig.
- All props are separate pieces with moving parts (flags, smoke) on their own layers.

### Build order
1. One complete zone first: Base Camp → Camp 1, with the background loop, catch-up climb, one hut and the three core items.
2. Then the asset set for all five zones in the same style.
3. Then the remaining zones in SpriteKit.

## Visual basics
- 1 Oct 2026: **App UI system decided** — see `design/design-system.md` and the Summit Design System artifact (https://claude.ai/artifact/Wu3gB6HsGuyfjJ5zpNXr4Y): follow-the-sky Day/Night themes, summit gold as the one accent, climbers keep their own colours, SF Pro Rounded for UI + Unbounded for numbers, native iOS patterns. Supersedes the mockup palettes and fonts below.

### Earlier mockup values (superseded)
- Avatars: coloured circles with initials and a white ring (to be replaced by the character). Each friend has a fixed colour (e.g. blue, teal, purple, pink), and you use the accent colour (orange #E8702A).
- Trail Cam palette: sky #D9E6EE, volcanic slope #9C6B55, ink #1B1E23. Fonts: Unbounded (numbers) + Onest (UI).
- Ridge palette: warm off-white #F5F2EC, slate mountain #3E5871. Fonts: Bricolage Grotesque + DM Sans.
- To do: settle on one palette and one font pair for both views.

## Game values used in mockups
- 1 flight ≈ 3 m of elevation (Apple Health Flights Climbed).
- Mt. Fuji 3,776 m ≈ 1,259 flights. 30-day race with 5 friends.

## Open / to define later
- Other screens: Friends, Peaks (mountain picker), Me/profile, onboarding.
- How the zoom transition works.
- Exact scroll range and parallax speeds (tune on device).
- Milestones and stations for each mountain.
- Nudge mechanics and notifications.
- Final brand, colours, type, and app icon.
