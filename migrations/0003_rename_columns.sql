ALTER TABLE events RENAME COLUMN event_at TO ts;
DROP INDEX events_event_at_idx;
CREATE INDEX on events (ts);
