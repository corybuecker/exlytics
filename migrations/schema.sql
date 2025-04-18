--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Debian 17.4-1.pgdg120+2)
-- Dumped by pg_dump version 17.4 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: events; Type: TABLE; Schema: public; Owner: exlytics
--

CREATE TABLE public.events (
    ts timestamp with time zone NOT NULL,
    event jsonb NOT NULL
);


ALTER TABLE public.events OWNER TO exlytics;

--
-- Name: events_event_idx; Type: INDEX; Schema: public; Owner: exlytics
--

CREATE INDEX events_event_idx ON public.events USING gin (event);


--
-- Name: events_ts_idx; Type: INDEX; Schema: public; Owner: exlytics
--

CREATE INDEX events_ts_idx ON public.events USING btree (ts);


--
-- PostgreSQL database dump complete
--

