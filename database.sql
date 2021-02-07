create database exlytics;

\c exlytics

drop schema if exists public;
create schema if not exists exlytics;

drop table if exists exlytics.events;

create table if not exists exlytics.events (
  time timestamp without time zone not null,
  metadata jsonb
);
