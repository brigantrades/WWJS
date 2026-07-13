# WWJS Design System

This is a living snapshot of the interface as of July 2026. Verify details against the repository before changing UI, especially `lib/core/app_theme.dart`, `lib/screens/`, and `lib/widgets/`.

## Product character

WWJS is a guided Christian prayer experience. Its interface should feel peaceful, warm, grounded, hopeful, and personal. The visual metaphor is a dawn-lit path toward the cross. Favor spacious composition and gentle reassurance. Avoid clinical dashboards, loud growth tactics, dense controls, competitive streak mechanics, and guilt-driven copy.

## Visual language

- Light background: warm parchment `#F7F4ED`
- Light surface: warm white `#FFFDF8`
- Primary forest: `#263D35`
- Sage accent: `#758675`
- Dawn peach: `#E7B89B`
- Main charcoal text: `#24302C`
- Divider: `#DDD8CE`
- Disabled: `#E7E3DA`
- Dark background: `#17241F`
- Dark surface: `#213129`
- Dark text: `#F6F1E7`
- Dark primary currently resolves to `#A6B9A4`

Use color semantically. Forest carries strong hierarchy; sage supports primary actions, progress, selection, and completion; peach is atmospheric. Warm neutrals should dominate.

## Typography

Display and prominent editorial headings use a platform serif with Georgia and Times New Roman fallbacks. Body and controls use the platform sans serif.

- Display large: 48, line height 1.05
- Display medium: 38, line height 1.1
- Headline medium: 30, line height 1.2
- Title large: 20, semibold
- Body large: 17, line height 1.5
- Body medium: 15, line height 1.4
- Label large: 17, semibold

Keep long scripture and prayer text highly readable. Do not use the serif for dense utility content or small labels.

## Shape, depth, and spacing

- Filled buttons are 56 high with a 16 radius.
- Global cards use a 24 radius and no default elevation.
- Prayer cards use an 18 radius, 12 bottom spacing, subtle elevation, and a forest-tinted shadow.
- Hero content panels may use a 32 radius with a soft black shadow around 8% opacity.
- Spacing commonly follows 4/8-point increments, with 16 or 24 horizontal page insets.

Use rounded geometry to feel approachable, but keep the radius hierarchy consistent. Reserve shadows for separation from artwork or for meaningful interactive layers.

## Imagery and brand

- `assets/branding/wwjs-logo.png`: circular sunrise, cross, dark-green hills, and a white winding path.
- `assets/images/dawn-path.png`: luminous portrait landscape used by `DawnArtwork` for immersive hero regions.
- `assets/images/prayer-header-watercolor.png`: quiet sage-and-gold watercolor texture suited to devotional headers and restrained decorative use.

Do not place essential text over busy imagery without a stable contrast treatment. Crop artwork around the path/cross focal point and test different aspect ratios.

## Established components and patterns

- `BrandLogo`: canonical logo presentation with semantic labeling.
- `DawnArtwork`: top-of-screen hero, including a compact player treatment.
- `PrayerCard`: rounded list card with a sage day tile, completion badge, semantic day status, and restrained shadow.
- Today and onboarding: dawn artwork topped by the logo and “WWJS” with “What Would Jesus Say?” beneath it, followed by a rounded surface that overlaps the artwork. Onboarding also shows the “Pray with Jesus” tagline; Today uses the quieter two-line wordmark.
- Today prayer panel: a small, widely spaced “PRAY WITH JESUS” eyebrow sits above the prayer title, reinforcing the tagline without competing with the title or primary action.
- Player: compact dawn hero with filled-tonal home and favorite actions, followed by the prayer and playback experience.
- Bottom navigation: warm surface, sage translucent selection indicator, 12-point labels.
- Subscription and update dialogs: use the existing modal components and their hierarchy before inventing a new sheet or dialog pattern.

## Core journeys

1. Onboarding introduces the promise and begins setup.
2. Commitment establishes a sustainable prayer time.
3. Today centers the current prayer and its primary action.
4. Prayer lists support browsing, saved prayers, completion, and favorites.
5. Player supports immersion, scripture context, progress, pause/resume, seeking, favorite, exit, completion, and replay.
6. Settings handles preferences, current day, theme, reset, update, and supporting actions.

Protect the direct path from opening the app to beginning prayer. New features should not interrupt it without a compelling reason.

## UX writing

- Use calm, direct verbs: “Begin prayer,” “Continue,” “Pray again,” “Save,” and “Return home.”
- Explain progress without judgment. Prefer “You can continue where you left off” over language implying failure.
- Use “Day N” consistently when identifying prayer content.
- Keep confirmations specific: name what will happen and whether it can be undone.
- Avoid religious clichés when simple, sincere language is clearer.

## Known implementation considerations

- The app supports light and dark themes through `buildAppTheme`.
- Layouts use Material 3 and Flutter platform semantics.
- Some screens use large fixed artwork heights and overlapping panels; always test short screens, landscape, and large text before extending these patterns.
- The visual system is partly encoded in individual screens. When repetition emerges, move stable decisions into theme extensions or shared widgets rather than duplicating values.
