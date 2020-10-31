-- This must be run as a database superuser
create role exlytics;
alter role exlytics login;
alter role exlytics password 'exlytics';
create database exlytics owner exlytics;

\c exlytics

drop schema public cascade;
create schema exlytics authorization exlytics;