create table public.app_update_config (
  platform text primary key check (platform in ('android', 'ios')),
  latest_build integer not null check (latest_build > 0),
  store_url text not null check (length(trim(store_url)) > 0),
  enabled boolean not null default true,
  updated_at timestamptz not null default now()
);

comment on table public.app_update_config is
  'Controls the client-side update prompt independently for Android and iOS.';

alter table public.app_update_config enable row level security;

grant select on table public.app_update_config to anon, authenticated;

create policy "App update configuration is public"
on public.app_update_config
for select
to anon, authenticated
using (true);

-- Build 6 intentionally makes the prompt visible to build 5 during internal
-- testing. Raise latest_build whenever a newer store build is available.
insert into public.app_update_config (platform, latest_build, store_url)
values
  ('android', 6, 'market://details?id=com.wwjs.wwjs'),
  ('ios', 6, 'https://testflight.apple.com')
on conflict (platform) do update set
  latest_build = excluded.latest_build,
  store_url = excluded.store_url,
  enabled = excluded.enabled,
  updated_at = now();
