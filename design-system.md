# Summit – Design System

Source of truth: the Summit Design System artifact (https://claude.ai/artifact/Wu3gB6HsGuyfjJ5zpNXr4Y). This file is a portable copy for other tools.

Race your friends up a real mountain with the stairs you climb in real life. This is the UI system for the Summit iOS app: menus, lists, sheets, buttons and the chrome around the mountain scene.

**In one line:** the mountain scene is the colourful hero; everything around it is calm, premium, native iOS.

## Principles

1. **The scene is the hero.** The layered mountain, sky and weather carry the colour. UI chrome stays neutral (snow white by day, night blue by night) so it never competes.
2. **Feels like iOS, made with care.** Use native patterns first: large titles, grouped inset lists, bottom sheets with a grabber, a translucent tab bar, SF Symbols, haptics. Premium comes from restraint, spacing and motion quality, not decoration.
3. **One accent: summit gold.** `sun` marks what matters right now: your climber's ring, an active boost, an item ready to use, a reward. If everything is gold, nothing is.
4. **Climbers own their colours.** Each player picks a body colour (`climber-*`). Those colours appear only on climbers and their small avatar dots, never on buttons or text, so UI and players never get confused.
5. **Numbers are the trophy.** Flights, metres and ranks get the display face (Unbounded). Everything else is SF Pro Rounded.

## Themes: follow the sky

Two themes, picked by the real time at the user's location (and by iOS dark mode as an override):

| Theme | When | Feel |
|---|---|---|
| **Day** (`day`) | Sunrise to sunset (dawn and golden hour included) | Snow: cool off-white `surface-0`, white cards, ink text |
| **Night** (`night`) | Sunset to sunrise | Night sky: deep blue `surface-0`, slate cards, light text |

The scene art has its own palettes per time of day and weather (see the project's `design.md`). The UI only switches between these two.

## Colour

- **Surfaces:** `surface-0` screen background → `surface-1` cards, rows, sheets → `surface-2` sunken fills (tracks, inputs, secondary buttons, chips). Over the scene use `surface-glass` with a background blur, never a solid card.
- **Text:** `ink` for content, `ink-muted` for secondary, `ink-faint` only for disabled/placeholder.
- **Actions:** primary buttons are an `action` ink pill with `on-action` text. Item and reward actions use a `sun` pill with `on-sun` text. Secondary buttons use `surface-2` with `ink` text.
- **Accent as text:** use `sun-text`, never `sun` (gold text on white fails contrast).
- **Status:** `success` for camps, summits and gains; `danger` for hits and losses; `glacier` for links and info. Always pair status colour with a word or an SF Symbol, never colour alone.
- **Identity:** `brand-night` and `brand-snow` are for the app icon, cover and marketing, not UI chrome.
- **Climbers:** eight `climber-*` colours. Players choose one at onboarding; two players in the same race can share a colour (the name label tells them apart).

All text pairs meet WCAG AA (4.5:1) in both themes; `ink-faint` is the only exception and is never used for content.

## Typography

- **SF Pro Rounded** (`--font-rounded`) for all UI text. In SwiftUI: `.fontDesign(.rounded)` with Dynamic Type text styles (`.body`, `.headline`…), so text scales with the user's settings. Outside Apple devices (mockups, web), Nunito is the stand-in.
- **Unbounded** (`--font-display`) for numbers and mountain names only: `hero-number`, `stat-number`, `display-title`. One hero number per screen. Unbounded is a free Google Font (OFL) and ships inside the app.
- Sizes follow the iOS type scale (Body 17, Headline 17 semibold, Callout 15, Footnote 13, Large Title 34). Use tabular figures for anything that counts or lines up.
- Sentence case everywhere. Uppercase only for `eyebrow` labels, sparingly.

## Layout and shape

- 16pt screen margins (`space-4`), 8pt rhythm. Touch targets at least 44×44pt.
- Continuous (squircle) corners on every rounded shape: `radius-sm` controls, `radius-md` grouped lists and tiles, `radius-lg` floating cards, `radius-xl` sheets, `radius-pill` buttons, chips and the tab bar.
- Lists on `surface-0` use grouped inset sections with hairline (`line`) separators and no shadow. Only things floating over the scene get `shadow-card`; sheets and the zoom-out button get `shadow-float`.

## Iconography

- SF Symbols in the app (regular or medium weight, matched to the text next to them). Custom game glyphs (snowball, shortcut sign, chocolate bar, mountain button) are drawn to sit with SF Symbols: rounded ends, ~1.8pt strokes at 24pt, simple filled shapes.
- No emoji in UI chrome. Emoji are fine in push notification text.

## Motion and feel

- Spring animations (iOS default springs: response ~0.35s, no bounce for UI; a little bounce for game moments).
- Haptics: light impact on taps that change state, success notification at camps and summit, a rigid impact when you get hit.
- Respect Reduce Motion: the scene's background loop pauses and replays shorten to a cross-fade.

## Voice

Short, warm and a little cheeky, like a friend on the trail. Use the game's words: flights, camps, summit, race. Talk to the player ("You passed Mira"), never about the system. Numbers do the bragging, so skip exclamation marks except at the summit.

- Good: "Lena hit you with a snowball. −3 flights."
- Good: "That was no shortcut. +5 flights detour."
- Avoid: "Oops! Something went wrong!!" → "Couldn't sync. Pull down to try again."

## Components here

Button, Chip, FriendRow, ItemSlot, TabBar and Sheet show the patterns above in both themes. They are HTML previews for design reference; the app builds them natively in SwiftUI.


## Tokens

### Colour (Day / Night)

| Token | Day | Night | Use |
|---|---|---|---|
| `surface-0` | #F2F4F7 | #0B1120 | App background behind lists and screens (Day: snow, Night: night sky). |
| `surface-1` | #FFFFFF | #151D31 | Cards, grouped list rows, sheets. |
| `surface-2` | #E7EBF0 | #1F2840 | Sunken fills: inputs, progress tracks, secondary buttons, chips. |
| `surface-glass` | rgba(255,255,255,0.72) | rgba(16,23,40,0.72) | Translucent material over the scene (tab bar, header chips, floating buttons). Always with a background blur (iOS .regularMaterial). |
| `line` | #D6DCE4 | #2B3552 | Hairline separators (0.5pt) and card borders on surface-0. |
| `ink` | #121A28 | #EEF2F8 | Primary text and icons on any surface. |
| `ink-muted` | #566174 | #A2ADC0 | Secondary text: subtitles, metadata, inactive tab labels. |
| `ink-faint` | #8A94A3 | #69748B | Disabled text and placeholder only. Below 4.5:1 on purpose; never for content. |
| `action` | #121A28 | #EEF2F8 | Primary button fill (an ink pill). Inverts per theme. |
| `on-action` | #FFFFFF | #0B1120 | Text and icons on action. |
| `sun` | #F2B33D | #F2B33D | The one accent: summit gold. Highlights, active boosts, item actions, the 'you' ring, rewards. Fill only; never as text on light surfaces. |
| `on-sun` | #2B1D04 | #2B1D04 | Text and icons on sun. |
| `sun-text` | #8A5A00 | #F5C462 | Accent as text or icon on surface-0/1 (e.g. '1.5×', 'Camp 2 reached'). |
| `glacier` | #2D6CB0 | #8DB9EA | Links and informational tint. Secondary to sun. |
| `success` | #23804F | #6BCB96 | Camp reached, summit, positive deltas (+flights). |
| `danger` | #C23B2B | #FF8C7A | Hits and losses (−3 flights), destructive actions. |
| `brand-night` | #121A33 | #2C3D6B | Identity colour: night sky. Cover, icon, marketing; not UI chrome. |
| `brand-snow` | #E4EAF1 | #E4EAF1 | Identity colour: snow. Cover, icon, marketing. |
| `climber-glacier` | #3D7FD9 | #3D7FD9 | Climber body colour. Players pick one; never used for UI. |
| `climber-lagoon` | #24A094 | #24A094 | Climber body colour. |
| `climber-moss` | #5C9E3E | #5C9E3E | Climber body colour. |
| `climber-sunflower` | #E5B020 | #E5B020 | Climber body colour. |
| `climber-ember` | #E8702A | #E8702A | Climber body colour. |
| `climber-coral` | #E05A5A | #E05A5A | Climber body colour. |
| `climber-berry` | #D6457A | #D6457A | Climber body colour. |
| `climber-plum` | #8E5BD0 | #8E5BD0 | Climber body colour. |

### Type

Families: rounded = SF Pro Rounded (stand-in: Nunito); display = Unbounded.

| Style | Family | Size / line | Weight | Use |
|---|---|---|---|---|
| `hero-number` | display | 84px / 84px | 800 | Today's flights on Trail Cam. One per screen. |
| `stat-number` | display | 28px / 32px | 700 | Stat tiles, summit card, race results. |
| `display-title` | display | 30px / 36px | 700 | Mountain names and celebration titles only. |
| `large-title` | rounded | 34px / 41px | 700 | iOS large navigation title (Friends, Peaks, Me). |
| `title` | rounded | 22px / 28px | 700 | Section and sheet titles. |
| `headline` | rounded | 17px / 22px | 600 | List row titles, button labels. |
| `body` | rounded | 17px / 22px | 400 | Default text (iOS Body). |
| `callout` | rounded | 15px / 20px | 500 | Secondary row text, chips, small buttons. |
| `footnote` | rounded | 13px / 18px | 500 | Metadata and helper text. |
| `eyebrow` | rounded | 12px / 16px | 700 | Uppercase labels above titles. Sparingly. |
| `tab-label` | rounded | 10px / 12px | 600 | Tab bar labels (iOS standard). |

### Spacing

| Token | Value | Use |
|---|---|---|
| `space-1` | 4px | Icon-to-label gaps. |
| `space-2` | 8px | Tight groups, chip padding. |
| `space-3` | 12px | Row inner gaps. |
| `space-4` | 16px | Screen side margin (iOS standard), card padding. |
| `space-5` | 24px | Between groups on a screen. |
| `space-6` | 32px | Between sections; sheet top padding. |
| `space-7` | 48px | Hero breathing room. |

### Radius

| Token | Value | Use |
|---|---|---|
| `radius-sm` | 10px | Small controls, item icons. Use continuous corners (iOS .continuous). |
| `radius-md` | 16px | Grouped list sections, stat tiles. |
| `radius-lg` | 24px | Cards floating over the scene. |
| `radius-xl` | 32px | Sheets (top corners) and the widget. |
| `radius-pill` | 999px | Buttons, chips, tab bar, avatars. |

### Shadow

| Token | Day | Night | Use |
|---|---|---|---|
| `shadow-card` | `0 1px 2px rgba(18,26,40,0.06), 0 8px 24px rgba(18,26,40,0.08)` | `0 1px 2px rgba(0,0,0,0.40), 0 8px 24px rgba(0,0,0,0.35)` | Cards and floating controls over the scene. Lists on surface-0 use no shadow. |
| `shadow-float` | `0 10px 30px rgba(18,26,40,0.18)` | `0 10px 30px rgba(0,0,0,0.5)` | Sheets and the zoom-out mountain button. |

## Components

### Button

Pill buttons in four roles: primary (ink), sun (item and reward actions), secondary (sunken), and plain text links.

- One primary or sun button per screen area. Sun is only for game actions (throw, place, eat, claim).
- Height 50pt (36pt small), full pill radius, SF Pro Rounded semibold 17.
- Disabled uses `surface-2` with `ink-faint` and says why ("Waiting for 2").
- Light haptic on tap.

### Chip

Small rounded labels for state: race day, weather, active boost, hits and gains.

- Over the scene use the glass version (`surface-glass` + blur + `shadow-card`).
- Boost chips are `sun` with a live countdown.
- Losses and gains pair `danger`/`success` text with an arrow or check symbol, never colour alone.

### FriendRow

Grouped inset list row for leaderboards and friend lists.

- Rank in the display face, climber dot in the player's own climber colour, name, one line of context, altitude right-aligned with tabular figures.
- Your row gets a `sun` ring around your dot instead of a different background.
- Hairline separators inset to the text; no shadows on `surface-0` lists.

### ItemSlot

The item you're holding, floating over the scene with its one action.

- Glass card, `radius-lg`, slot ringed in `sun` when an item is ready.
- Empty slot says when the next find comes ("Next find in 6 flights").
- Tapping the action opens the target sheet.

### TabBar

Floating translucent pill tab bar with four tabs: Climb, Friends, Peaks, Me.

- `surface-glass` with a strong background blur over the scene; the selected tab sits on `surface-2`.
- Icons 24pt with 10pt labels. In the app use the native TabView with SF Symbols where possible.

### Sheet

iOS bottom sheet for choices like picking a snowball target or placing a shortcut sign.

- `surface-1`, `radius-xl` top corners, grabber, `shadow-float`. Medium detent by default.
- Title, one line of what happens, options as sunken rows (selected = `sun` ring), one sun action that names the result ("Throw at Lena").
