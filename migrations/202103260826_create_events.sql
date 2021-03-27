create table if not exists events (
  time timestamp without time zone not null
  , metadata jsonb
  , inserted_at timestamp without time zone not null default now()
  , updated_at timestamp without time zone not null default now()
);

create index if not exists events_time on events(time);
create index if not exists events_metadata on events using gin (metadata);