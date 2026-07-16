# WWJS: Pray With Jesus

**Pray with Jesus.**

A private, offline-first daily prayer app for iOS and Android, built with Flutter.

## Run

```sh
flutter pub get
flutter run
```

## Content and audio

Prayer content lives in `lib/data/prayers.dart`. Each entry includes its local audio asset and section timestamps.

The editorial source of truth for used and future Scripture passages is
`content/verse_plan.json`. It currently maps the opening 30-day journey, including
the theme arc, pastoral tone, genre, and individual canonical verse IDs for every
passage. Agents and editors must update this registry when a future passage is
approved so selections are not left only in conversation history.

Validate the plan after every editorial change:

```sh
dart run tool/verse_plan_validator.dart
flutter test test/content/verse_plan_test.dart
```

The validator rejects duplicate days, duplicate or overlapping canonical verses,
missing planning fields, and gaps in the planned sequence. The Flutter test also
checks that bundled prayer titles and references match all registry entries marked
`existing`.

- `assets/audio/day_001.mp3` is the current Day 1 recording.
- `assets/audio/day_002.mp3` is the current Day 2 recording.
- Days 3 through 5 intentionally use silent placeholder audio while their final narration is produced.
- Replace placeholder files with production MP3 files, then update the asset paths and section timestamps in `lib/data/prayers.dart`.

Keep production narration mono at 44.1 kHz and normalize spoken audio consistently before release.

## Local app state

Onboarding date, unlocked day, favorites, completed prayers, reminder preferences, theme, text scale, and playback positions are stored through `shared_preferences`. There is no user-created WWJS profile.

`LocalActivityStore` keeps privacy-minimized usage aggregates in the same local
preferences store. It retains 90 days of daily totals plus lifetime counters for
sessions, screen views, prayer opens, playback, completions, favorites, and
reminder outcomes. It stores no account, install, device, advertising, or network
identifier and has no upload path. Resetting app data removes this history. Any
future sharing feature must require consent and export a reviewed summary rather
than the stored history automatically.

## Validation

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```
