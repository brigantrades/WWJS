# Supabase setup

1. Run `supabase/migrations/20260712044044_create_prayer_content.sql` in the
   Supabase SQL Editor (or use `supabase db push` after linking the project).
2. In Storage, upload each audio file to the public `prayer-audio` bucket as
   either MP3 or M4A (for example, `day_001.mp3` or `day_001.m4a`). Store the
   uploaded filename in `prayer_days.audio_path`; playback also tries the other
   supported extension when the configured file is unavailable.
3. Run `supabase/seed.sql` as a starter, then add or edit rows through SQL or the
   Table Editor. Keep `is_published = false` until the audio and content are ready.
4. Run the app with:

   ```sh
   flutter run \
     --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
     --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
   ```

Never put a secret or service-role key in the Flutter app.

## Update prompt

`app_update_config` controls the update modal per platform. Set
`latest_build` to the build number available to testers or customers. Builds
below that number see the prompt on startup. `Maybe later` snoozes the same
update for 24 hours.

For iOS internal testing, replace the placeholder `store_url` with the app's
TestFlight public invitation link if one is available. Before production,
replace it with the final App Store listing URL.
