create table public.google_play_entitlements (
  purchase_token_hash text primary key,
  purchase_token text not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id text not null check (product_id = 'wwjs_full_access'),
  base_plan_id text,
  subscription_state text not null,
  expires_at timestamptz,
  is_entitled boolean not null default false,
  linked_purchase_token_hash text,
  last_verified_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.google_play_entitlements is
  'Server-only Google Play purchase tokens and their last verified entitlement state.';

create index google_play_entitlements_user_updated_idx
  on public.google_play_entitlements (user_id, updated_at desc);

alter table public.google_play_entitlements enable row level security;

revoke all on table public.google_play_entitlements from anon, authenticated;
grant all on table public.google_play_entitlements to service_role;
