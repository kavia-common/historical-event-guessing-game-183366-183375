--
-- PostgreSQL database dump
--

\restrict Q04oxlN6Ps6pzoq2oBUbbPYbhGvzowWbeaLGkd5fewhZFgfgZnP5yGDheSMT4WT

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS myapp;
--
-- Name: myapp; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE myapp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE myapp OWNER TO postgres;

\unrestrict Q04oxlN6Ps6pzoq2oBUbbPYbhGvzowWbeaLGkd5fewhZFgfgZnP5yGDheSMT4WT
\connect myapp
\restrict Q04oxlN6Ps6pzoq2oBUbbPYbhGvzowWbeaLGkd5fewhZFgfgZnP5yGDheSMT4WT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: clues; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.clues (
    id integer NOT NULL,
    event_id integer NOT NULL,
    order_index integer NOT NULL,
    text text NOT NULL
);


ALTER TABLE public.clues OWNER TO appuser;

--
-- Name: clues_id_seq; Type: SEQUENCE; Schema: public; Owner: appuser
--

CREATE SEQUENCE public.clues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clues_id_seq OWNER TO appuser;

--
-- Name: clues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: appuser
--

ALTER SEQUENCE public.clues_id_seq OWNED BY public.clues.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.events (
    id integer NOT NULL,
    month integer NOT NULL,
    day integer NOT NULL,
    year integer,
    title character varying(255) NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.events OWNER TO appuser;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: appuser
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.events_id_seq OWNER TO appuser;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: appuser
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: game_sessions; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.game_sessions (
    id uuid NOT NULL,
    event_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    attempts_used integer NOT NULL,
    clues_revealed integer NOT NULL,
    is_completed boolean NOT NULL,
    is_success boolean NOT NULL
);


ALTER TABLE public.game_sessions OWNER TO appuser;

--
-- Name: clues id; Type: DEFAULT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.clues ALTER COLUMN id SET DEFAULT nextval('public.clues_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Data for Name: clues; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.clues (id, event_id, order_index, text) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.events (id, month, day, year, title, description, created_at) FROM stdin;
\.


--
-- Data for Name: game_sessions; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.game_sessions (id, event_id, created_at, attempts_used, clues_revealed, is_completed, is_success) FROM stdin;
\.


--
-- Name: clues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: appuser
--

SELECT pg_catalog.setval('public.clues_id_seq', 1, false);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: appuser
--

SELECT pg_catalog.setval('public.events_id_seq', 1, false);


--
-- Name: clues clues_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.clues
    ADD CONSTRAINT clues_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: game_sessions game_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.game_sessions
    ADD CONSTRAINT game_sessions_pkey PRIMARY KEY (id);


--
-- Name: clues uq_clue_event_order; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.clues
    ADD CONSTRAINT uq_clue_event_order UNIQUE (event_id, order_index);


--
-- Name: events uq_event_month_day_title; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT uq_event_month_day_title UNIQUE (month, day, title);


--
-- Name: clues clues_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.clues
    ADD CONSTRAINT clues_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: game_sessions game_sessions_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.game_sessions
    ADD CONSTRAINT game_sessions_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE RESTRICT;


--
-- Name: DATABASE myapp; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE myapp TO appuser;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TYPES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO appuser;


--
-- PostgreSQL database dump complete
--

\unrestrict Q04oxlN6Ps6pzoq2oBUbbPYbhGvzowWbeaLGkd5fewhZFgfgZnP5yGDheSMT4WT

