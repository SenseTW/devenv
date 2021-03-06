--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Drop databases
--

DROP DATABASE h;
DROP DATABASE htest;
DROP DATABASE sensetw;




--
-- Drop roles
--

DROP ROLE postgres;
DROP ROLE sensetw;


--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;
CREATE ROLE sensetw;
ALTER ROLE sensetw WITH SUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md5cb41d833b2af618b872b0254c83c4c2d';






--
-- Database creation
--

CREATE DATABASE h WITH TEMPLATE = template0 OWNER = sensetw;
CREATE DATABASE htest WITH TEMPLATE = template0 OWNER = sensetw;
CREATE DATABASE sensetw WITH TEMPLATE = template0 OWNER = postgres;
REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


\connect h

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.9
-- Dumped by pg_dump version 9.6.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: authclient_grant_type; Type: TYPE; Schema: public; Owner: sensetw
--

CREATE TYPE public.authclient_grant_type AS ENUM (
    'authorization_code',
    'client_credentials',
    'password',
    'jwt_bearer'
);


ALTER TYPE public.authclient_grant_type OWNER TO sensetw;

--
-- Name: authclient_response_type; Type: TYPE; Schema: public; Owner: sensetw
--

CREATE TYPE public.authclient_response_type AS ENUM (
    'code',
    'token'
);


ALTER TYPE public.authclient_response_type OWNER TO sensetw;

--
-- Name: group_joinable_by; Type: TYPE; Schema: public; Owner: sensetw
--

CREATE TYPE public.group_joinable_by AS ENUM (
    'authority'
);


ALTER TYPE public.group_joinable_by OWNER TO sensetw;

--
-- Name: group_readable_by; Type: TYPE; Schema: public; Owner: sensetw
--

CREATE TYPE public.group_readable_by AS ENUM (
    'members',
    'world'
);


ALTER TYPE public.group_readable_by OWNER TO sensetw;

--
-- Name: group_writeable_by; Type: TYPE; Schema: public; Owner: sensetw
--

CREATE TYPE public.group_writeable_by AS ENUM (
    'authority',
    'members'
);


ALTER TYPE public.group_writeable_by OWNER TO sensetw;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activation; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.activation (
    id integer NOT NULL,
    code text NOT NULL
);


ALTER TABLE public.activation OWNER TO sensetw;

--
-- Name: activation_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.activation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.activation_id_seq OWNER TO sensetw;

--
-- Name: activation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.activation_id_seq OWNED BY public.activation.id;


--
-- Name: annotation; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.annotation (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    userid text NOT NULL,
    groupid text DEFAULT '__world__'::text NOT NULL,
    text text,
    text_rendered text,
    tags text[],
    shared boolean DEFAULT false NOT NULL,
    target_uri text,
    target_uri_normalized text,
    target_selectors jsonb DEFAULT '[]'::jsonb,
    "references" uuid[] DEFAULT ARRAY[]::uuid[],
    extra jsonb DEFAULT '{}'::jsonb NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    document_id integer NOT NULL
);


ALTER TABLE public.annotation OWNER TO sensetw;

--
-- Name: annotation_moderation; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.annotation_moderation (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    annotation_id uuid NOT NULL
);


ALTER TABLE public.annotation_moderation OWNER TO sensetw;

--
-- Name: annotation_moderation_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.annotation_moderation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.annotation_moderation_id_seq OWNER TO sensetw;

--
-- Name: annotation_moderation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.annotation_moderation_id_seq OWNED BY public.annotation_moderation.id;


--
-- Name: authclient; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.authclient (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    name text,
    secret text,
    authority text NOT NULL,
    grant_type public.authclient_grant_type,
    response_type public.authclient_response_type,
    redirect_uri text,
    trusted boolean DEFAULT false NOT NULL,
    CONSTRAINT ck__authclient__authz_grant_redirect_uri CHECK (((grant_type <> 'authorization_code'::public.authclient_grant_type) OR (redirect_uri IS NOT NULL)))
);


ALTER TABLE public.authclient OWNER TO sensetw;

--
-- Name: authticket; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.authticket (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id text NOT NULL,
    expires timestamp without time zone NOT NULL,
    user_id integer NOT NULL,
    user_userid text NOT NULL
);


ALTER TABLE public.authticket OWNER TO sensetw;

--
-- Name: authzcode; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.authzcode (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    user_id integer NOT NULL,
    authclient_id uuid NOT NULL,
    code text NOT NULL,
    expires timestamp without time zone NOT NULL
);


ALTER TABLE public.authzcode OWNER TO sensetw;

--
-- Name: authzcode_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.authzcode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.authzcode_id_seq OWNER TO sensetw;

--
-- Name: authzcode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.authzcode_id_seq OWNED BY public.authzcode.id;


--
-- Name: blocklist; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.blocklist (
    id integer NOT NULL,
    uri text NOT NULL
);


ALTER TABLE public.blocklist OWNER TO sensetw;

--
-- Name: blocklist_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.blocklist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blocklist_id_seq OWNER TO sensetw;

--
-- Name: blocklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.blocklist_id_seq OWNED BY public.blocklist.id;


--
-- Name: document; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.document (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    title text,
    web_uri text
);


ALTER TABLE public.document OWNER TO sensetw;

--
-- Name: document_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_id_seq OWNER TO sensetw;

--
-- Name: document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.document_id_seq OWNED BY public.document.id;


--
-- Name: document_meta; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.document_meta (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    claimant text NOT NULL,
    claimant_normalized text NOT NULL,
    type text NOT NULL,
    value text[] NOT NULL,
    document_id integer NOT NULL
);


ALTER TABLE public.document_meta OWNER TO sensetw;

--
-- Name: document_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.document_meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_meta_id_seq OWNER TO sensetw;

--
-- Name: document_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.document_meta_id_seq OWNED BY public.document_meta.id;


--
-- Name: document_uri; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.document_uri (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    claimant text NOT NULL,
    claimant_normalized text NOT NULL,
    uri text NOT NULL,
    uri_normalized text NOT NULL,
    type text DEFAULT ''::text NOT NULL,
    content_type text DEFAULT ''::text NOT NULL,
    document_id integer NOT NULL
);


ALTER TABLE public.document_uri OWNER TO sensetw;

--
-- Name: document_uri_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.document_uri_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_uri_id_seq OWNER TO sensetw;

--
-- Name: document_uri_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.document_uri_id_seq OWNED BY public.document_uri.id;


--
-- Name: feature; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.feature (
    id integer NOT NULL,
    name text NOT NULL,
    everyone boolean DEFAULT false NOT NULL,
    admins boolean DEFAULT false NOT NULL,
    staff boolean DEFAULT false NOT NULL
);


ALTER TABLE public.feature OWNER TO sensetw;

--
-- Name: feature_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.feature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.feature_id_seq OWNER TO sensetw;

--
-- Name: feature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.feature_id_seq OWNED BY public.feature.id;


--
-- Name: featurecohort; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.featurecohort (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.featurecohort OWNER TO sensetw;

--
-- Name: featurecohort_feature; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.featurecohort_feature (
    id integer NOT NULL,
    cohort_id integer NOT NULL,
    feature_id integer NOT NULL
);


ALTER TABLE public.featurecohort_feature OWNER TO sensetw;

--
-- Name: featurecohort_feature_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.featurecohort_feature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.featurecohort_feature_id_seq OWNER TO sensetw;

--
-- Name: featurecohort_feature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.featurecohort_feature_id_seq OWNED BY public.featurecohort_feature.id;


--
-- Name: featurecohort_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.featurecohort_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.featurecohort_id_seq OWNER TO sensetw;

--
-- Name: featurecohort_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.featurecohort_id_seq OWNED BY public.featurecohort.id;


--
-- Name: featurecohort_user; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.featurecohort_user (
    id integer NOT NULL,
    cohort_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.featurecohort_user OWNER TO sensetw;

--
-- Name: featurecohort_user_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.featurecohort_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.featurecohort_user_id_seq OWNER TO sensetw;

--
-- Name: featurecohort_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.featurecohort_user_id_seq OWNED BY public.featurecohort_user.id;


--
-- Name: flag; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.flag (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    annotation_id uuid NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.flag OWNER TO sensetw;

--
-- Name: flag_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.flag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flag_id_seq OWNER TO sensetw;

--
-- Name: flag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.flag_id_seq OWNED BY public.flag.id;


--
-- Name: group; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public."group" (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    pubid text NOT NULL,
    authority text NOT NULL,
    name text NOT NULL,
    creator_id integer,
    description text,
    joinable_by public.group_joinable_by,
    readable_by public.group_readable_by,
    writeable_by public.group_writeable_by
);


ALTER TABLE public."group" OWNER TO sensetw;

--
-- Name: group_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_id_seq OWNER TO sensetw;

--
-- Name: group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.group_id_seq OWNED BY public."group".id;


--
-- Name: setting; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.setting (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    key text NOT NULL,
    value text
);


ALTER TABLE public.setting OWNER TO sensetw;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    uri text NOT NULL,
    type character varying(64) NOT NULL,
    active boolean NOT NULL
);


ALTER TABLE public.subscriptions OWNER TO sensetw;

--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subscriptions_id_seq OWNER TO sensetw;

--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: token; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.token (
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    userid text NOT NULL,
    value text NOT NULL,
    expires timestamp without time zone,
    refresh_token text,
    refresh_token_expires timestamp without time zone,
    authclient_id uuid
);


ALTER TABLE public.token OWNER TO sensetw;

--
-- Name: token_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.token_id_seq OWNER TO sensetw;

--
-- Name: token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.token_id_seq OWNED BY public.token.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    username text NOT NULL,
    authority text NOT NULL,
    display_name text,
    description text,
    location text,
    uri text,
    orcid text,
    admin boolean DEFAULT false NOT NULL,
    staff boolean DEFAULT false NOT NULL,
    nipsa boolean DEFAULT false NOT NULL,
    sidebar_tutorial_dismissed boolean DEFAULT false,
    email text NOT NULL,
    last_login_date timestamp without time zone DEFAULT now() NOT NULL,
    registered_date timestamp without time zone DEFAULT now() NOT NULL,
    activation_id integer,
    password text,
    password_updated timestamp without time zone,
    salt text
);


ALTER TABLE public."user" OWNER TO sensetw;

--
-- Name: user_group; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.user_group (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.user_group OWNER TO sensetw;

--
-- Name: user_group_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.user_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_group_id_seq OWNER TO sensetw;

--
-- Name: user_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.user_group_id_seq OWNED BY public.user_group.id;


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO sensetw;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: activation id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.activation ALTER COLUMN id SET DEFAULT nextval('public.activation_id_seq'::regclass);


--
-- Name: annotation_moderation id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.annotation_moderation ALTER COLUMN id SET DEFAULT nextval('public.annotation_moderation_id_seq'::regclass);


--
-- Name: authzcode id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.authzcode ALTER COLUMN id SET DEFAULT nextval('public.authzcode_id_seq'::regclass);


--
-- Name: blocklist id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.blocklist ALTER COLUMN id SET DEFAULT nextval('public.blocklist_id_seq'::regclass);


--
-- Name: document id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.document ALTER COLUMN id SET DEFAULT nextval('public.document_id_seq'::regclass);


--
-- Name: document_meta id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.document_meta ALTER COLUMN id SET DEFAULT nextval('public.document_meta_id_seq'::regclass);


--
-- Name: document_uri id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.document_uri ALTER COLUMN id SET DEFAULT nextval('public.document_uri_id_seq'::regclass);


--
-- Name: feature id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.feature ALTER COLUMN id SET DEFAULT nextval('public.feature_id_seq'::regclass);


--
-- Name: featurecohort id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort ALTER COLUMN id SET DEFAULT nextval('public.featurecohort_id_seq'::regclass);


--
-- Name: featurecohort_feature id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort_feature ALTER COLUMN id SET DEFAULT nextval('public.featurecohort_feature_id_seq'::regclass);


--
-- Name: featurecohort_user id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort_user ALTER COLUMN id SET DEFAULT nextval('public.featurecohort_user_id_seq'::regclass);


--
-- Name: flag id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.flag ALTER COLUMN id SET DEFAULT nextval('public.flag_id_seq'::regclass);


--
-- Name: group id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."group" ALTER COLUMN id SET DEFAULT nextval('public.group_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: token id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.token ALTER COLUMN id SET DEFAULT nextval('public.token_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Name: user_group id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.user_group ALTER COLUMN id SET DEFAULT nextval('public.user_group_id_seq'::regclass);


--
-- Data for Name: activation; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.activation (id, code) FROM stdin;
\.


--
-- Name: activation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.activation_id_seq', 1, false);


--
-- Data for Name: annotation; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.annotation (id, created, updated, userid, groupid, text, text_rendered, tags, shared, target_uri, target_uri_normalized, target_selectors, "references", extra, deleted, document_id) FROM stdin;
\.


--
-- Data for Name: annotation_moderation; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.annotation_moderation (created, updated, id, annotation_id) FROM stdin;
\.


--
-- Name: annotation_moderation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.annotation_moderation_id_seq', 1, false);


--
-- Data for Name: authclient; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.authclient (created, updated, id, name, secret, authority, grant_type, response_type, redirect_uri, trusted) FROM stdin;
2018-07-24 03:02:55.780244	2018-07-24 03:02:55.780249	10133a7c-8eee-11e8-a828-dfa174f8daca	app	\N	sense.tw	authorization_code	code	https://localhost:8040	t
2018-07-24 03:03:23.200105	2018-07-24 03:03:23.200111	206a618e-8eee-11e8-a828-47ee24cc62d4	JWT	nu_PkRPTds6mDJ3O4vg5ZDI8y2vJOQPkWEGj1NxGJr0	sense.tw	jwt_bearer	\N	\N	f
\.


--
-- Data for Name: authticket; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.authticket (created, updated, id, expires, user_id, user_userid) FROM stdin;
2018-07-24 03:00:58.454753	2018-07-24 03:04:28.370486	_toleUYDmlilc7WfgPhtQS3LgKpzb_YmanAlOoRbehs	2018-07-31 03:04:28.369407	2	acct:admin@sense.tw
\.


--
-- Data for Name: authzcode; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.authzcode (created, updated, id, user_id, authclient_id, code, expires) FROM stdin;
\.


--
-- Name: authzcode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.authzcode_id_seq', 1, false);


--
-- Data for Name: blocklist; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.blocklist (id, uri) FROM stdin;
\.


--
-- Name: blocklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.blocklist_id_seq', 1, false);


--
-- Data for Name: document; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.document (created, updated, id, title, web_uri) FROM stdin;
\.


--
-- Name: document_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.document_id_seq', 1, false);


--
-- Data for Name: document_meta; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.document_meta (created, updated, id, claimant, claimant_normalized, type, value, document_id) FROM stdin;
\.


--
-- Name: document_meta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.document_meta_id_seq', 1, false);


--
-- Data for Name: document_uri; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.document_uri (created, updated, id, claimant, claimant_normalized, uri, uri_normalized, type, content_type, document_id) FROM stdin;
\.


--
-- Name: document_uri_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.document_uri_id_seq', 1, false);


--
-- Data for Name: feature; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.feature (id, name, everyone, admins, staff) FROM stdin;
\.


--
-- Name: feature_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.feature_id_seq', 1, false);


--
-- Data for Name: featurecohort; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.featurecohort (created, updated, id, name) FROM stdin;
\.


--
-- Data for Name: featurecohort_feature; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.featurecohort_feature (id, cohort_id, feature_id) FROM stdin;
\.


--
-- Name: featurecohort_feature_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.featurecohort_feature_id_seq', 1, false);


--
-- Name: featurecohort_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.featurecohort_id_seq', 1, false);


--
-- Data for Name: featurecohort_user; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.featurecohort_user (id, cohort_id, user_id) FROM stdin;
\.


--
-- Name: featurecohort_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.featurecohort_user_id_seq', 1, false);


--
-- Data for Name: flag; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.flag (created, updated, id, annotation_id, user_id) FROM stdin;
\.


--
-- Name: flag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.flag_id_seq', 1, false);


--
-- Data for Name: group; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public."group" (created, updated, id, pubid, authority, name, creator_id, description, joinable_by, readable_by, writeable_by) FROM stdin;
2018-07-24 02:58:55.284309	2018-07-24 02:58:55.284316	1	__world__	sense.tw	Public	\N	\N	\N	world	authority
\.


--
-- Name: group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.group_id_seq', 33, true);


--
-- Data for Name: setting; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.setting (created, updated, key, value) FROM stdin;
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.subscriptions (id, uri, type, active) FROM stdin;
1	acct:test@sense.tw	reply	t
2	acct:admin@sense.tw	reply	t
\.


--
-- Name: subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.subscriptions_id_seq', 33, true);


--
-- Data for Name: token; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.token (created, updated, id, userid, value, expires, refresh_token, refresh_token_expires, authclient_id) FROM stdin;
\.


--
-- Name: token_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.token_id_seq', 1, false);


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public."user" (id, username, authority, display_name, description, location, uri, orcid, admin, staff, nipsa, sidebar_tutorial_dismissed, email, last_login_date, registered_date, activation_id, password, password_updated, salt) FROM stdin;
1	test	sense.tw	\N	\N	\N	\N	\N	f	f	f	f	test@test.com	2018-07-24 02:59:20.670546	2018-07-24 02:59:20.670556	\N	$2b$12$fVyH89lRJc47jiQGGCmVl.4gPTiQTPuAQYGuo0WtjQZqGLuzXFQ9m	2018-07-24 02:59:20.659921	\N
2	admin	sense.tw	\N	\N	\N	\N	\N	t	f	f	f	admin@test.com	2018-07-24 03:00:58.446851	2018-07-24 02:59:42.339402	\N	$2b$12$5scwRHjNgt.FXWWmea1SlevjbgpdClsNf0m6QhhNPacbpn5/XbTPG	2018-07-24 02:59:42.330931	\N
\.


--
-- Data for Name: user_group; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.user_group (id, user_id, group_id) FROM stdin;
\.


--
-- Name: user_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.user_group_id_seq', 1, false);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.user_id_seq', 33, true);


--
-- Name: activation pk__activation; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.activation
    ADD CONSTRAINT pk__activation PRIMARY KEY (id);


--
-- Name: annotation pk__annotation; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.annotation
    ADD CONSTRAINT pk__annotation PRIMARY KEY (id);


--
-- Name: annotation_moderation pk__annotation_moderation; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.annotation_moderation
    ADD CONSTRAINT pk__annotation_moderation PRIMARY KEY (id);


--
-- Name: authclient pk__authclient; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.authclient
    ADD CONSTRAINT pk__authclient PRIMARY KEY (id);


--
-- Name: authticket pk__authticket; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.authticket
    ADD CONSTRAINT pk__authticket PRIMARY KEY (id);


--
-- Name: authzcode pk__authzcode; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.authzcode
    ADD CONSTRAINT pk__authzcode PRIMARY KEY (id);


--
-- Name: blocklist pk__blocklist; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.blocklist
    ADD CONSTRAINT pk__blocklist PRIMARY KEY (id);


--
-- Name: document pk__document; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT pk__document PRIMARY KEY (id);


--
-- Name: document_meta pk__document_meta; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.document_meta
    ADD CONSTRAINT pk__document_meta PRIMARY KEY (id);


--
-- Name: document_uri pk__document_uri; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.document_uri
    ADD CONSTRAINT pk__document_uri PRIMARY KEY (id);


--
-- Name: feature pk__feature; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT pk__feature PRIMARY KEY (id);


--
-- Name: featurecohort pk__featurecohort; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort
    ADD CONSTRAINT pk__featurecohort PRIMARY KEY (id);


--
-- Name: featurecohort_feature pk__featurecohort_feature; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort_feature
    ADD CONSTRAINT pk__featurecohort_feature PRIMARY KEY (id);


--
-- Name: featurecohort_user pk__featurecohort_user; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort_user
    ADD CONSTRAINT pk__featurecohort_user PRIMARY KEY (id);


--
-- Name: flag pk__flag; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.flag
    ADD CONSTRAINT pk__flag PRIMARY KEY (id);


--
-- Name: group pk__group; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT pk__group PRIMARY KEY (id);


--
-- Name: setting pk__setting; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.setting
    ADD CONSTRAINT pk__setting PRIMARY KEY (key);


--
-- Name: subscriptions pk__subscriptions; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT pk__subscriptions PRIMARY KEY (id);


--
-- Name: token pk__token; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT pk__token PRIMARY KEY (id);


--
-- Name: user pk__user; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT pk__user PRIMARY KEY (id);


--
-- Name: user_group pk__user_group; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.user_group
    ADD CONSTRAINT pk__user_group PRIMARY KEY (id);


--
-- Name: activation uq__activation__code; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.activation
    ADD CONSTRAINT uq__activation__code UNIQUE (code);


--
-- Name: authzcode uq__authzcode__code; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.authzcode
    ADD CONSTRAINT uq__authzcode__code UNIQUE (code);


--
-- Name: blocklist uq__blocklist__uri; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.blocklist
    ADD CONSTRAINT uq__blocklist__uri UNIQUE (uri);


--
-- Name: document_meta uq__document_meta__claimant_normalized; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.document_meta
    ADD CONSTRAINT uq__document_meta__claimant_normalized UNIQUE (claimant_normalized, type);


--
-- Name: document_uri uq__document_uri__claimant_normalized; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.document_uri
    ADD CONSTRAINT uq__document_uri__claimant_normalized UNIQUE (claimant_normalized, uri_normalized, type, content_type);


--
-- Name: feature uq__feature__name; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT uq__feature__name UNIQUE (name);


--
-- Name: featurecohort_feature uq__featurecohort_feature__cohort_id; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort_feature
    ADD CONSTRAINT uq__featurecohort_feature__cohort_id UNIQUE (cohort_id, feature_id);


--
-- Name: featurecohort_user uq__featurecohort_user__cohort_id; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort_user
    ADD CONSTRAINT uq__featurecohort_user__cohort_id UNIQUE (cohort_id, user_id);


--
-- Name: flag uq__flag__annotation_id; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.flag
    ADD CONSTRAINT uq__flag__annotation_id UNIQUE (annotation_id, user_id);


--
-- Name: group uq__group__pubid; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT uq__group__pubid UNIQUE (pubid);


--
-- Name: token uq__token__refresh_token; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT uq__token__refresh_token UNIQUE (refresh_token);


--
-- Name: token uq__token__value; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT uq__token__value UNIQUE (value);


--
-- Name: user uq__user__email; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT uq__user__email UNIQUE (email, authority);


--
-- Name: user_group uq__user_group__user_id; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.user_group
    ADD CONSTRAINT uq__user_group__user_id UNIQUE (user_id, group_id);


--
-- Name: ix__annotation_groupid; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__annotation_groupid ON public.annotation USING btree (groupid);


--
-- Name: ix__annotation_tags; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__annotation_tags ON public.annotation USING gin (tags);


--
-- Name: ix__annotation_thread_root; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__annotation_thread_root ON public.annotation USING btree (("references"[1]));


--
-- Name: ix__annotation_updated; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__annotation_updated ON public.annotation USING btree (updated);


--
-- Name: ix__annotation_userid; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__annotation_userid ON public.annotation USING btree (userid);


--
-- Name: ix__document_meta_document_id; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__document_meta_document_id ON public.document_meta USING btree (document_id);


--
-- Name: ix__document_meta_updated; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__document_meta_updated ON public.document_meta USING btree (updated);


--
-- Name: ix__document_uri_document_id; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__document_uri_document_id ON public.document_uri USING btree (document_id);


--
-- Name: ix__document_uri_updated; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__document_uri_updated ON public.document_uri USING btree (updated);


--
-- Name: ix__document_uri_uri_normalized; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__document_uri_uri_normalized ON public.document_uri USING btree (uri_normalized);


--
-- Name: ix__featurecohort_name; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__featurecohort_name ON public.featurecohort USING btree (name);


--
-- Name: ix__flag_user_id; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__flag_user_id ON public.flag USING btree (user_id);


--
-- Name: ix__group_name; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__group_name ON public."group" USING btree (name);


--
-- Name: ix__group_readable_by; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX ix__group_readable_by ON public."group" USING btree (readable_by);


--
-- Name: ix__user__userid; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE UNIQUE INDEX ix__user__userid ON public."user" USING btree (lower(replace(username, '.'::text, ''::text)), authority);


--
-- Name: subs_uri_idx_subscriptions; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX subs_uri_idx_subscriptions ON public.subscriptions USING btree (uri);


--
-- Name: annotation fk__annotation__document_id__document; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.annotation
    ADD CONSTRAINT fk__annotation__document_id__document FOREIGN KEY (document_id) REFERENCES public.document(id);


--
-- Name: annotation_moderation fk__annotation_moderation__annotation_id__annotation; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.annotation_moderation
    ADD CONSTRAINT fk__annotation_moderation__annotation_id__annotation FOREIGN KEY (annotation_id) REFERENCES public.annotation(id) ON DELETE CASCADE;


--
-- Name: authticket fk__authticket__user_id__user; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.authticket
    ADD CONSTRAINT fk__authticket__user_id__user FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: authzcode fk__authzcode__authclient_id__authclient; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.authzcode
    ADD CONSTRAINT fk__authzcode__authclient_id__authclient FOREIGN KEY (authclient_id) REFERENCES public.authclient(id) ON DELETE CASCADE;


--
-- Name: authzcode fk__authzcode__user_id__user; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.authzcode
    ADD CONSTRAINT fk__authzcode__user_id__user FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: document_meta fk__document_meta__document_id__document; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.document_meta
    ADD CONSTRAINT fk__document_meta__document_id__document FOREIGN KEY (document_id) REFERENCES public.document(id);


--
-- Name: document_uri fk__document_uri__document_id__document; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.document_uri
    ADD CONSTRAINT fk__document_uri__document_id__document FOREIGN KEY (document_id) REFERENCES public.document(id);


--
-- Name: featurecohort_feature fk__featurecohort_feature__cohort_id__featurecohort; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort_feature
    ADD CONSTRAINT fk__featurecohort_feature__cohort_id__featurecohort FOREIGN KEY (cohort_id) REFERENCES public.featurecohort(id);


--
-- Name: featurecohort_feature fk__featurecohort_feature__feature_id__feature; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort_feature
    ADD CONSTRAINT fk__featurecohort_feature__feature_id__feature FOREIGN KEY (feature_id) REFERENCES public.feature(id) ON DELETE CASCADE;


--
-- Name: featurecohort_user fk__featurecohort_user__cohort_id__featurecohort; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort_user
    ADD CONSTRAINT fk__featurecohort_user__cohort_id__featurecohort FOREIGN KEY (cohort_id) REFERENCES public.featurecohort(id);


--
-- Name: featurecohort_user fk__featurecohort_user__user_id__user; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.featurecohort_user
    ADD CONSTRAINT fk__featurecohort_user__user_id__user FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: flag fk__flag__annotation_id__annotation; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.flag
    ADD CONSTRAINT fk__flag__annotation_id__annotation FOREIGN KEY (annotation_id) REFERENCES public.annotation(id) ON DELETE CASCADE;


--
-- Name: flag fk__flag__user_id__user; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.flag
    ADD CONSTRAINT fk__flag__user_id__user FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: group fk__group__creator_id__user; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT fk__group__creator_id__user FOREIGN KEY (creator_id) REFERENCES public."user"(id);


--
-- Name: token fk__token__authclient_id__authclient; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT fk__token__authclient_id__authclient FOREIGN KEY (authclient_id) REFERENCES public.authclient(id) ON DELETE CASCADE;


--
-- Name: user fk__user__activation_id__activation; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT fk__user__activation_id__activation FOREIGN KEY (activation_id) REFERENCES public.activation(id);


--
-- Name: user_group fk__user_group__group_id__group; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.user_group
    ADD CONSTRAINT fk__user_group__group_id__group FOREIGN KEY (group_id) REFERENCES public."group"(id);


--
-- Name: user_group fk__user_group__user_id__user; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.user_group
    ADD CONSTRAINT fk__user_group__user_id__user FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- PostgreSQL database dump complete
--

\connect htest

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.9
-- Dumped by pg_dump version 9.6.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- PostgreSQL database dump complete
--

\connect postgres

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.9
-- Dumped by pg_dump version 9.6.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- PostgreSQL database dump complete
--

\connect sensetw

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.9
-- Dumped by pg_dump version 9.6.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: cardtype; Type: TYPE; Schema: public; Owner: sensetw
--

CREATE TYPE public.cardtype AS ENUM (
    'NORMAL',
    'QUESTION',
    'ANSWER',
    'NOTE'
);


ALTER TYPE public.cardtype OWNER TO sensetw;

--
-- Name: objecttype; Type: TYPE; Schema: public; Owner: sensetw
--

CREATE TYPE public.objecttype AS ENUM (
    'NONE',
    'CARD',
    'BOX'
);


ALTER TYPE public.objecttype OWNER TO sensetw;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: annotation; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.annotation (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "mapId" uuid NOT NULL,
    "cardId" uuid,
    document jsonb,
    target jsonb
);


ALTER TABLE public.annotation OWNER TO sensetw;

--
-- Name: box; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.box (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    summary character varying(255) DEFAULT ''::character varying NOT NULL,
    tags character varying(255) DEFAULT ''::character varying NOT NULL,
    "mapId" uuid NOT NULL
);


ALTER TABLE public.box OWNER TO sensetw;

--
-- Name: TABLE box; Type: COMMENT; Schema: public; Owner: sensetw
--

COMMENT ON TABLE public.box IS 'Box data';


--
-- Name: card; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.card (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    summary character varying(255) DEFAULT ''::character varying NOT NULL,
    description character varying(255) DEFAULT ''::character varying NOT NULL,
    tags character varying(255) DEFAULT ''::character varying NOT NULL,
    "saidBy" character varying(255) DEFAULT ''::character varying NOT NULL,
    stakeholder character varying(255) DEFAULT ''::character varying NOT NULL,
    url character varying(255) DEFAULT ''::character varying NOT NULL,
    "cardType" public.cardtype DEFAULT 'NORMAL'::public.cardtype NOT NULL,
    "mapId" uuid NOT NULL
);


ALTER TABLE public.card OWNER TO sensetw;

--
-- Name: TABLE card; Type: COMMENT; Schema: public; Owner: sensetw
--

COMMENT ON TABLE public.card IS 'Card data';


--
-- Name: edge; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.edge (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "mapId" uuid NOT NULL,
    "fromId" uuid,
    "toId" uuid
);


ALTER TABLE public.edge OWNER TO sensetw;

--
-- Name: TABLE edge; Type: COMMENT; Schema: public; Owner: sensetw
--

COMMENT ON TABLE public.edge IS 'Edge data';


--
-- Name: map; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.map (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    name character varying(255),
    description character varying(255),
    tags character varying(255),
    image character varying(255),
    type character varying(255)
);


ALTER TABLE public.map OWNER TO sensetw;

--
-- Name: TABLE map; Type: COMMENT; Schema: public; Owner: sensetw
--

COMMENT ON TABLE public.map IS 'Map data';


--
-- Name: oauth_authorization_code; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.oauth_authorization_code (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "authorizationCode" character varying(64),
    "expiresAt" timestamp without time zone,
    "redirectUri" character varying(512),
    "clientId" uuid,
    "userId" uuid
);


ALTER TABLE public.oauth_authorization_code OWNER TO sensetw;

--
-- Name: oauth_token; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.oauth_token (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "accessToken" character varying(64),
    "accessTokenExpiresAt" timestamp without time zone,
    "refreshToken" character varying(64),
    "refreshTokenExpiresAt" timestamp without time zone,
    "clientId" uuid,
    "userId" uuid
);


ALTER TABLE public.oauth_token OWNER TO sensetw;

--
-- Name: object; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.object (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "mapId" uuid NOT NULL,
    x double precision DEFAULT 0 NOT NULL,
    y double precision DEFAULT 0 NOT NULL,
    "zIndex" integer DEFAULT 0 NOT NULL,
    "objectType" public.objecttype NOT NULL,
    "boxId" uuid,
    "cardId" uuid,
    "belongsToId" uuid,
    width double precision DEFAULT 0,
    height double precision DEFAULT 0
);


ALTER TABLE public.object OWNER TO sensetw;

--
-- Name: TABLE object; Type: COMMENT; Schema: public; Owner: sensetw
--

COMMENT ON TABLE public.object IS 'Object data';


--
-- Name: pgmigrations; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public.pgmigrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    run_on timestamp without time zone NOT NULL
);


ALTER TABLE public.pgmigrations OWNER TO sensetw;

--
-- Name: pgmigrations_id_seq; Type: SEQUENCE; Schema: public; Owner: sensetw
--

CREATE SEQUENCE public.pgmigrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pgmigrations_id_seq OWNER TO sensetw;

--
-- Name: pgmigrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sensetw
--

ALTER SEQUENCE public.pgmigrations_id_seq OWNED BY public.pgmigrations.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: sensetw
--

CREATE TABLE public."user" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    username character varying(32) NOT NULL,
    salthash character varying(64) NOT NULL,
    email character varying(128) NOT NULL
);


ALTER TABLE public."user" OWNER TO sensetw;

--
-- Name: pgmigrations id; Type: DEFAULT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.pgmigrations ALTER COLUMN id SET DEFAULT nextval('public.pgmigrations_id_seq'::regclass);


--
-- Data for Name: annotation; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.annotation (id, "createdAt", "updatedAt", "mapId", "cardId", document, target) FROM stdin;
\.


--
-- Data for Name: box; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.box (id, "createdAt", "updatedAt", title, summary, tags, "mapId") FROM stdin;
\.


--
-- Data for Name: card; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.card (id, "createdAt", "updatedAt", title, summary, description, tags, "saidBy", stakeholder, url, "cardType", "mapId") FROM stdin;
\.


--
-- Data for Name: edge; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.edge (id, "createdAt", "updatedAt", "mapId", "fromId", "toId") FROM stdin;
\.


--
-- Data for Name: map; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.map (id, "createdAt", "updatedAt", name, description, tags, image, type) FROM stdin;
1dbab857-942d-41d0-baa1-82fa70b0d773	2018-07-24 02:34:28.187409	2018-07-24 02:34:28.187409	\N	\N	\N	\N	\N
\.


--
-- Data for Name: oauth_authorization_code; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.oauth_authorization_code (id, "authorizationCode", "expiresAt", "redirectUri", "clientId", "userId") FROM stdin;
\.


--
-- Data for Name: oauth_token; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.oauth_token (id, "accessToken", "accessTokenExpiresAt", "refreshToken", "refreshTokenExpiresAt", "clientId", "userId") FROM stdin;
\.


--
-- Data for Name: object; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.object (id, "createdAt", "updatedAt", "mapId", x, y, "zIndex", "objectType", "boxId", "cardId", "belongsToId", width, height) FROM stdin;
\.


--
-- Data for Name: pgmigrations; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public.pgmigrations (id, name, run_on) FROM stdin;
1	1528427639797_initial	2018-07-24 02:34:28.187409
2	1529462794279_object-dimension	2018-07-24 02:34:28.187409
3	1529894750713_seed-default-map	2018-07-24 02:34:28.187409
4	1530247885947_create-user-account	2018-07-24 02:34:28.187409
5	1530427903503_oauth-token-tables	2018-07-24 02:34:28.187409
6	1530516456976_add-map-info-columns	2018-07-24 02:34:28.187409
7	1530523707671_add-map-type-column	2018-07-24 02:34:28.187409
8	1530777822453_create-annotation-table	2018-07-24 02:34:28.187409
\.


--
-- Name: pgmigrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sensetw
--

SELECT pg_catalog.setval('public.pgmigrations_id_seq', 8, true);


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: sensetw
--

COPY public."user" (id, "createdAt", "updatedAt", username, salthash, email) FROM stdin;
\.


--
-- Name: annotation annotation_pkey; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.annotation
    ADD CONSTRAINT annotation_pkey PRIMARY KEY (id);


--
-- Name: box box_pkey; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.box
    ADD CONSTRAINT box_pkey PRIMARY KEY (id);


--
-- Name: card card_pkey; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.card
    ADD CONSTRAINT card_pkey PRIMARY KEY (id);


--
-- Name: edge edge_pkey; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.edge
    ADD CONSTRAINT edge_pkey PRIMARY KEY (id);


--
-- Name: map map_pkey; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.map
    ADD CONSTRAINT map_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorization_code oauth_authorization_code_pkey; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.oauth_authorization_code
    ADD CONSTRAINT oauth_authorization_code_pkey PRIMARY KEY (id);


--
-- Name: oauth_token oauth_token_pkey; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.oauth_token
    ADD CONSTRAINT oauth_token_pkey PRIMARY KEY (id);


--
-- Name: object object_pkey; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT object_pkey PRIMARY KEY (id);


--
-- Name: pgmigrations pgmigrations_pkey; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.pgmigrations
    ADD CONSTRAINT pgmigrations_pkey PRIMARY KEY (id);


--
-- Name: user user_email_key; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_email_key UNIQUE (email);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user user_username_key; Type: CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_username_key UNIQUE (username);


--
-- Name: annotation_cardId_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "annotation_cardId_index" ON public.annotation USING btree ("cardId");


--
-- Name: box_mapId_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "box_mapId_index" ON public.box USING btree ("mapId");


--
-- Name: card_mapId_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "card_mapId_index" ON public.card USING btree ("mapId");


--
-- Name: edge_mapId_fromId_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "edge_mapId_fromId_index" ON public.edge USING btree ("mapId", "fromId");


--
-- Name: edge_mapId_toId_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "edge_mapId_toId_index" ON public.edge USING btree ("mapId", "toId");


--
-- Name: map_name_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX map_name_index ON public.map USING btree (name);


--
-- Name: map_type_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX map_type_index ON public.map USING btree (type);


--
-- Name: oauth_authorization_code_authorizationCode_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "oauth_authorization_code_authorizationCode_index" ON public.oauth_authorization_code USING btree ("authorizationCode");


--
-- Name: oauth_authorization_code_expiresAt_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "oauth_authorization_code_expiresAt_index" ON public.oauth_authorization_code USING btree ("expiresAt");


--
-- Name: oauth_token_accessTokenExpiresAt_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "oauth_token_accessTokenExpiresAt_index" ON public.oauth_token USING btree ("accessTokenExpiresAt");


--
-- Name: oauth_token_accessToken_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "oauth_token_accessToken_index" ON public.oauth_token USING btree ("accessToken");


--
-- Name: oauth_token_refreshTokenExpiresAt_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "oauth_token_refreshTokenExpiresAt_index" ON public.oauth_token USING btree ("refreshTokenExpiresAt");


--
-- Name: oauth_token_refreshToken_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "oauth_token_refreshToken_index" ON public.oauth_token USING btree ("refreshToken");


--
-- Name: object_belongsToId_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "object_belongsToId_index" ON public.object USING btree ("belongsToId");


--
-- Name: object_boxId_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "object_boxId_index" ON public.object USING btree ("boxId");


--
-- Name: object_cardId_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "object_cardId_index" ON public.object USING btree ("cardId");


--
-- Name: object_mapId_objectType_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX "object_mapId_objectType_index" ON public.object USING btree ("mapId", "objectType");


--
-- Name: user_email_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX user_email_index ON public."user" USING btree (email);


--
-- Name: user_username_index; Type: INDEX; Schema: public; Owner: sensetw
--

CREATE INDEX user_username_index ON public."user" USING btree (username);


--
-- Name: annotation annotation_cardId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.annotation
    ADD CONSTRAINT "annotation_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES public.card(id);


--
-- Name: annotation annotation_mapId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.annotation
    ADD CONSTRAINT "annotation_mapId_fkey" FOREIGN KEY ("mapId") REFERENCES public.map(id);


--
-- Name: box box_mapId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.box
    ADD CONSTRAINT "box_mapId_fkey" FOREIGN KEY ("mapId") REFERENCES public.map(id);


--
-- Name: card card_mapId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.card
    ADD CONSTRAINT "card_mapId_fkey" FOREIGN KEY ("mapId") REFERENCES public.map(id);


--
-- Name: edge edge_fromId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.edge
    ADD CONSTRAINT "edge_fromId_fkey" FOREIGN KEY ("fromId") REFERENCES public.object(id);


--
-- Name: edge edge_mapId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.edge
    ADD CONSTRAINT "edge_mapId_fkey" FOREIGN KEY ("mapId") REFERENCES public.map(id);


--
-- Name: edge edge_toId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.edge
    ADD CONSTRAINT "edge_toId_fkey" FOREIGN KEY ("toId") REFERENCES public.object(id);


--
-- Name: oauth_authorization_code oauth_authorization_code_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.oauth_authorization_code
    ADD CONSTRAINT "oauth_authorization_code_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id);


--
-- Name: oauth_token oauth_token_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.oauth_token
    ADD CONSTRAINT "oauth_token_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id);


--
-- Name: object object_belongsToId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT "object_belongsToId_fkey" FOREIGN KEY ("belongsToId") REFERENCES public.box(id);


--
-- Name: object object_boxId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT "object_boxId_fkey" FOREIGN KEY ("boxId") REFERENCES public.box(id);


--
-- Name: object object_cardId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT "object_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES public.card(id);


--
-- Name: object object_mapId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sensetw
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT "object_mapId_fkey" FOREIGN KEY ("mapId") REFERENCES public.map(id);


--
-- PostgreSQL database dump complete
--

\connect template1

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.9
-- Dumped by pg_dump version 9.6.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

