-- This must be run as a database superuser
create database exlytics;

\c exlytics

drop schema public cascade;

create role exlytics;
create role dashboard;

alter role exlytics login;
alter role dashboard login;

alter role exlytics password 'exlytics';
alter role dashboard password 'dashboard';

create schema authorization exlytics;
create schema authorization dashboard;
