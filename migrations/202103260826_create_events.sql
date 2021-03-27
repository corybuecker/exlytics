create table if not exists exlytics.events (
  time timestamp without time zone not null
  , metadata jsonb
  , inserted_at timestamp without time zone not null default now()
  , updated_at timestamp without time zone not null default now()
);

create index if not exists events_time on exlytics.events(time);
create index if not exists events_metadata on exlytics.events using gin (metadata);