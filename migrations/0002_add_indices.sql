create index on events (event_at);
create index on events using gin (event);