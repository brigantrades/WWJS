-- Upload the matching M4A to Storage bucket `prayer-audio` before publishing.
insert into public.prayer_days (
  day, title, scripture_reference, scripture_text, preparation_text,
  reflection_text, response_prayer, closing_text, audio_path, duration_ms,
  sections, has_production_audio, is_published
) values (
  1,
  'Come and Rest',
  'Matthew 11:28–30',
  '“Come to me, all you who labor and are heavily burdened, and I will give you rest.”',
  'Take a slow breath in. As you gently breathe out, allow yourself to become still.',
  'You have carried enough for today. Bring me what has made you tired and rest here with me.',
  'Jesus, I give you what I cannot carry today. Quiet my heart and renew my strength.',
  'Rest here for a moment. Amen.',
  'day_001.m4a',
  120000,
  '[
    {"type":"preparation","label":"Be still","text":"Take a slow breath in.","starts_at_ms":0},
    {"type":"scripture","label":"Scripture","text":"Come to me, and I will give you rest.","starts_at_ms":20000},
    {"type":"reflection","label":"Jesus speaks","text":"You have carried enough for today.","starts_at_ms":31000},
    {"type":"response","label":"Your prayer","text":"Jesus, I give you what I cannot carry today.","starts_at_ms":58000},
    {"type":"closing","label":"Amen","text":"Rest here for a moment. Amen.","starts_at_ms":66000}
  ]'::jsonb,
  true,
  true
)
on conflict (day) do update set
  title = excluded.title,
  scripture_reference = excluded.scripture_reference,
  scripture_text = excluded.scripture_text,
  preparation_text = excluded.preparation_text,
  reflection_text = excluded.reflection_text,
  response_prayer = excluded.response_prayer,
  closing_text = excluded.closing_text,
  audio_path = excluded.audio_path,
  duration_ms = excluded.duration_ms,
  sections = excluded.sections,
  has_production_audio = excluded.has_production_audio,
  is_published = excluded.is_published,
  updated_at = now();
