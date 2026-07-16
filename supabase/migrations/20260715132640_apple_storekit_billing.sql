create table if not exists public.apple_storekit_entitlements (
  original_transaction_id text primary key,
  latest_transaction_id text not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id text not null check (
    product_id in ('wwjs_full_access_monthly', 'wwjs_full_access_yearly')
  ),
  environment text not null check (environment in ('Production', 'Sandbox')),
  subscription_status integer not null,
  app_account_token uuid,
  expires_at timestamptz,
  revocation_date timestamptz,
  is_entitled boolean not null default false,
  last_verified_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists apple_storekit_entitlements_user_updated_idx
  on public.apple_storekit_entitlements (user_id, updated_at desc);

alter table public.apple_storekit_entitlements enable row level security;

revoke all on table public.apple_storekit_entitlements from anon, authenticated;
grant all on table public.apple_storekit_entitlements to service_role;
