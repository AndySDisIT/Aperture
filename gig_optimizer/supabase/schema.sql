create extension if not exists "uuid-ossp";

create table if not exists users (
  id uuid primary key default uuid_generate_v4(),
  email text not null,
  min_hourly_rate numeric not null default 0,
  max_distance_miles numeric not null default 0,
  available_start_time text not null,
  available_end_time text not null,
  created_at timestamptz not null default now()
);

create table if not exists sources (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  category text not null,
  typical_duration_minutes integer not null default 0,
  proof_requirements text not null,
  reliability_score numeric not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists gigs (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  source_id uuid not null references sources(id) on delete restrict,
  title text not null,
  pay numeric not null default 0,
  address text not null,
  latitude double precision not null,
  longitude double precision not null,
  deadline timestamptz not null,
  estimated_duration_minutes integer not null default 0,
  status text not null default 'available',
  created_at timestamptz not null default now(),
  constraint gigs_status_check check (status in ('available', 'approved', 'completed', 'submitted', 'paid'))
);

create table if not exists routes (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  date date not null,
  total_pay numeric not null default 0,
  total_drive_minutes integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists routestops (
  id uuid primary key default uuid_generate_v4(),
  route_id uuid not null references routes(id) on delete cascade,
  gig_id uuid not null references gigs(id) on delete cascade,
  stop_order integer not null default 0,
  arrival_time timestamptz not null,
  created_at timestamptz not null default now()
);

create index if not exists gigs_user_id_idx on gigs(user_id);
create index if not exists gigs_status_idx on gigs(status);
create index if not exists routestops_route_id_idx on routestops(route_id);
