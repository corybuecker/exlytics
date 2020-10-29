-- This must be run as a database superuser
create role exlytics;
create role dashboard;

alter role exlytics login;
alter role dashboard login;

alter role exlytics password 'exlytics';
alter role dashboard password 'dashboard';

create database exlytics owner exlytics;

\c exlytics

drop schema public cascade;
