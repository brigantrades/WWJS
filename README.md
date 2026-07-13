# WWJS: What Would Jesus Say?

**Pray with Jesus.**

A private, offline-first daily prayer app for iOS and Android, built with Flutter.

## Run

```sh
flutter pub get
flutter run
```

## Content and audio

Prayer content lives in `lib/data/prayers.dart`. Each entry includes its local audio asset and section timestamps.

- `assets/audio/day_001.mp3` is the current Day 1 recording.
- `assets/audio/day_002.mp3` is the current Day 2 recording.
- Days 3 through 5 intentionally use silent placeholder audio while their final narration is produced.
- Replace placeholder files with production MP3 files, then update the asset paths and section timestamps in `lib/data/prayers.dart`.

Keep production narration mono at 44.1 kHz and normalize spoken audio consistently before release.

## Local-only data

Onboarding date, unlocked day, favorites, completed prayers, reminder preferences, theme, text scale, and playback positions are stored through `shared_preferences`. There is no account or remote database.

## Validation

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```
