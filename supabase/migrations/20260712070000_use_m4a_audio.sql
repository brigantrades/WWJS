update public.prayer_days
set audio_path = 'day_001.m4a',
    updated_at = now()
where day = 1;
