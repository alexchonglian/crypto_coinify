--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: contributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contributions (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    reward_id integer,
    value numeric NOT NULL,
    confirmed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    anonymous boolean DEFAULT false,
    key text,
    credits boolean DEFAULT false,
    notified_finish boolean DEFAULT false,
    payment_method text,
    payment_token text,
    payment_id character varying(255),
    payer_name text,
    payer_email text,
    payer_document text,
    address_street text,
    address_number text,
    address_complement text,
    address_neighbourhood text,
    address_zip_code text,
    address_city text,
    address_state text,
    address_phone_number text,
    payment_choice text,
    payment_service_fee numeric,
    state character varying(255),
    referal_link text,
    coin_status character varying(255),
    amount integer,
    CONSTRAINT backers_value_positive CHECK ((value >= (0)::numeric))
);


--
-- Name: can_cancel(contributions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION can_cancel(contributions) RETURNS boolean
    LANGUAGE sql
    AS $_$
        select
          $1.state = 'waiting_confirmation' and
          (
            ((
              select count(1) as total_of_days
              from generate_series($1.created_at::date, (current_timestamp AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo'))::date, '1 day') day
              WHERE extract(dow from day) not in (0,1)
            )  > 4)
            OR
            (
              lower($1.payment_choice) = lower('DebitoBancario')
              AND
                (
                  select count(1) as total_of_days
                  from generate_series($1.created_at::date, (current_timestamp AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo'))::date, '1 day') day
                  WHERE extract(dow from day) not in (0,1)
                )  > 1)
          )
      $_$;


--
-- Name: can_refund(contributions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION can_refund(contributions) RETURNS boolean
    LANGUAGE sql
    AS $_$
        select
          $1.state IN('confirmed', 'requested_refund', 'refunded') AND
          NOT $1.credits AND
          EXISTS(
            SELECT true
              FROM projects p
              WHERE p.id = $1.project_id and p.state = 'failed'
          )
      $_$;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name text NOT NULL,
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    goal numeric NOT NULL,
    about text NOT NULL,
    headline text NOT NULL,
    video_url text,
    short_url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    about_html text,
    recommended boolean DEFAULT false,
    home_page_comment text,
    permalink text NOT NULL,
    video_thumbnail text,
    state character varying(255),
    online_days integer DEFAULT 0,
    online_date timestamp with time zone,
    how_know text,
    more_links text,
    first_contributions text,
    uploaded_image character varying(255),
    video_embed_url character varying(255),
    referal_link text,
    sent_to_analysis_at timestamp without time zone,
    audited_user_name text,
    audited_user_cpf text,
    audited_user_moip_login text,
    audited_user_phone_number text,
    sent_to_draft_at timestamp without time zone,
    rejected_at timestamp without time zone,
    koinname character varying(255),
    total_amount numeric,
    total_issued numeric,
    amount_mined numeric,
    sold numeric,
    redeemed numeric,
    price numeric,
    koin_powers json,
    koin_features json,
    CONSTRAINT projects_about_not_blank CHECK ((length(btrim(about)) > 0)),
    CONSTRAINT projects_headline_length_within CHECK (((length(headline) >= 1) AND (length(headline) <= 140))),
    CONSTRAINT projects_headline_not_blank CHECK ((length(btrim(headline)) > 0))
);


--
-- Name: expires_at(projects); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION expires_at(projects) RETURNS timestamp with time zone
    LANGUAGE sql
    AS $_$
     SELECT ((((($1.online_date AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo') + ($1.online_days || ' days')::interval)  )::date::text || ' 23:59:59')::timestamp AT TIME ZONE coalesce((SELECT value FROM settings WHERE name = 'timezone'), 'America/Sao_Paulo'))::timestamptz )               
    $_$;


--
-- Name: authorizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authorizations (
    id integer NOT NULL,
    oauth_provider_id integer NOT NULL,
    user_id integer NOT NULL,
    uid text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authorizations_id_seq OWNED BY authorizations.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name_pt text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name_en character varying(255),
    CONSTRAINT categories_name_not_blank CHECK ((length(btrim(name_pt)) > 0))
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: channel_partners; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channel_partners (
    id integer NOT NULL,
    url text NOT NULL,
    image text NOT NULL,
    channel_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: channel_partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channel_partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channel_partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channel_partners_id_seq OWNED BY channel_partners.id;


--
-- Name: channel_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channel_posts (
    id integer NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    body_html text NOT NULL,
    channel_id integer NOT NULL,
    user_id integer NOT NULL,
    visible boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    published_at timestamp without time zone
);


--
-- Name: channel_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channel_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channel_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channel_posts_id_seq OWNED BY channel_posts.id;


--
-- Name: channels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    permalink text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    twitter text,
    facebook text,
    email text,
    image text,
    website text,
    video_url text,
    how_it_works text,
    how_it_works_html text,
    terms_url character varying(255),
    video_embed_url text
);


--
-- Name: channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_id_seq OWNED BY channels.id;


--
-- Name: channels_projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels_projects (
    id integer NOT NULL,
    channel_id integer,
    project_id integer
);


--
-- Name: channels_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_projects_id_seq OWNED BY channels_projects.id;


--
-- Name: channels_subscribers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels_subscribers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: channels_subscribers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_subscribers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_subscribers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_subscribers_id_seq OWNED BY channels_subscribers.id;


--
-- Name: coins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coins (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    user_id integer NOT NULL,
    project_id integer,
    total_amount numeric(32,16) NOT NULL,
    total_issued numeric(32,16) DEFAULT 0 NOT NULL,
    sold numeric(32,16) DEFAULT 0 NOT NULL,
    redeemed numeric(32,16) DEFAULT 0 NOT NULL,
    price numeric(32,16) NOT NULL,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    koinpower character varying(255),
    features character varying(255),
    powers character varying(255),
    amount_mined integer
);


--
-- Name: coins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coins_id_seq OWNED BY coins.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    name text NOT NULL,
    value text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT configurations_name_not_blank CHECK ((length(btrim(name)) > 0))
);


--
-- Name: configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE configurations_id_seq OWNED BY settings.id;


--
-- Name: rewards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rewards (
    id integer NOT NULL,
    project_id integer NOT NULL,
    minimum_value numeric NOT NULL,
    maximum_contributions integer,
    description text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reindex_versions timestamp without time zone,
    row_order integer,
    days_to_delivery integer,
    CONSTRAINT rewards_maximum_backers_positive CHECK ((maximum_contributions >= 0)),
    CONSTRAINT rewards_minimum_value_positive CHECK ((minimum_value >= (0)::numeric))
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email text,
    name text,
    nickname text,
    bio text,
    image_url text,
    newsletter boolean DEFAULT false,
    project_updates boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    admin boolean DEFAULT false,
    full_name text,
    address_street text,
    address_number text,
    address_complement text,
    address_neighbourhood text,
    address_city text,
    address_state text,
    address_zip_code text,
    phone_number text,
    locale text DEFAULT 'pt'::text NOT NULL,
    cpf text,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    twitter character varying(255),
    facebook_link character varying(255),
    other_link character varying(255),
    uploaded_image text,
    moip_login character varying(255),
    state_inscription character varying(255),
    channel_id integer,
    deactivated_at timestamp without time zone,
    cp_key character varying(255),
    cp_address character varying(255),
    CONSTRAINT users_bio_length_within CHECK (((length(bio) >= 0) AND (length(bio) <= 140)))
);


--
-- Name: contribution_reports; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW contribution_reports AS
 SELECT b.project_id,
    u.name,
    b.value,
    r.minimum_value,
    r.description,
    b.payment_method,
    b.payment_choice,
    b.payment_service_fee,
    b.key,
    (b.created_at)::date AS created_at,
    (b.confirmed_at)::date AS confirmed_at,
    u.email,
    b.payer_email,
    b.payer_name,
    COALESCE(b.payer_document, u.cpf) AS cpf,
    u.address_street,
    u.address_complement,
    u.address_number,
    u.address_neighbourhood,
    u.address_city,
    u.address_state,
    u.address_zip_code,
    b.state
   FROM ((contributions b
   JOIN users u ON ((u.id = b.user_id)))
   LEFT JOIN rewards r ON ((r.id = b.reward_id)))
  WHERE ((b.state)::text = ANY ((ARRAY['confirmed'::character varying, 'refunded'::character varying, 'requested_refund'::character varying])::text[]));


--
-- Name: contribution_reports_for_project_owners; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW contribution_reports_for_project_owners AS
 SELECT b.project_id,
    COALESCE(r.id, 0) AS reward_id,
    p.user_id AS project_owner_id,
    r.description AS reward_description,
    (b.confirmed_at)::date AS confirmed_at,
    b.value AS contribution_value,
    (b.value * ( SELECT (settings.value)::numeric AS value
           FROM settings
          WHERE (settings.name = 'catarse_fee'::text))) AS service_fee,
    u.email AS user_email,
    u.name AS user_name,
    b.payer_email,
    b.payment_method,
    b.anonymous,
    b.state,
    COALESCE(b.address_street, u.address_street) AS street,
    COALESCE(b.address_complement, u.address_complement) AS complement,
    COALESCE(b.address_number, u.address_number) AS address_number,
    COALESCE(b.address_neighbourhood, u.address_neighbourhood) AS neighbourhood,
    COALESCE(b.address_city, u.address_city) AS city,
    COALESCE(b.address_state, u.address_state) AS address_state,
    COALESCE(b.address_zip_code, u.address_zip_code) AS zip_code
   FROM (((contributions b
   JOIN users u ON ((u.id = b.user_id)))
   JOIN projects p ON ((b.project_id = p.id)))
   LEFT JOIN rewards r ON ((r.id = b.reward_id)))
  WHERE ((b.state)::text = ANY ((ARRAY['confirmed'::character varying, 'waiting_confirmation'::character varying])::text[]));


--
-- Name: contributions_by_periods; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW contributions_by_periods AS
 WITH weeks AS (
         SELECT to_char(current_year_1.current_year, 'yyyy-mm W'::text) AS current_year,
            to_char(last_year_1.last_year, 'yyyy-mm W'::text) AS last_year,
            current_year_1.current_year AS label
           FROM (generate_series((now() - '49 days'::interval), now(), '7 days'::interval) current_year_1(current_year)
      JOIN generate_series((now() - '1 year 49 days'::interval), (now() - '1 year'::interval), '7 days'::interval) last_year_1(last_year) ON ((to_char(last_year_1.last_year, 'mm W'::text) = to_char(current_year_1.current_year, 'mm W'::text))))
        ), current_year AS (
         SELECT w.label,
            sum(cc.value) AS current_year
           FROM (contributions cc
      JOIN weeks w ON ((w.current_year = to_char(cc.confirmed_at, 'yyyy-mm W'::text))))
     WHERE ((cc.state)::text = 'confirmed'::text)
     GROUP BY w.label
        ), last_year AS (
         SELECT w.label,
            sum(cc.value) AS last_year
           FROM (contributions cc
      JOIN weeks w ON ((w.last_year = to_char(cc.confirmed_at, 'yyyy-mm W'::text))))
     WHERE ((cc.state)::text = 'confirmed'::text)
     GROUP BY w.label
        )
 SELECT current_year.label,
    current_year.current_year,
    last_year.last_year
   FROM (current_year
   JOIN last_year USING (label));


--
-- Name: contributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contributions_id_seq OWNED BY contributions.id;


--
-- Name: financial_reports; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW financial_reports AS
 SELECT p.name,
    u.moip_login,
    p.goal,
    expires_at(p.*) AS expires_at,
    p.state
   FROM (projects p
   JOIN users u ON ((u.id = p.user_id)));


--
-- Name: koin_features; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE koin_features (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    requirement double precision,
    coin_id integer
);


--
-- Name: koin_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE koin_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: koin_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE koin_features_id_seq OWNED BY koin_features.id;


--
-- Name: koin_powers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE koin_powers (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    cost double precision,
    coin_id integer
);


--
-- Name: koin_powers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE koin_powers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: koin_powers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE koin_powers_id_seq OWNED BY koin_powers.id;


--
-- Name: koin_reward_fulfills; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE koin_reward_fulfills (
    id integer NOT NULL,
    koin_reward_id integer,
    user_id integer,
    twitter_handle text,
    facebook_handle text,
    linkedin_handle text,
    trigger_status integer,
    fulfill_status character varying(255),
    fulfill_date date
);


--
-- Name: koin_reward_fulfills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE koin_reward_fulfills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: koin_reward_fulfills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE koin_reward_fulfills_id_seq OWNED BY koin_reward_fulfills.id;


--
-- Name: koin_rewards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE koin_rewards (
    id integer NOT NULL,
    coin_id integer,
    trigger text,
    exp_date date,
    amount integer,
    cap integer,
    options text
);


--
-- Name: koin_rewards_fulfills; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE koin_rewards_fulfills (
    id integer NOT NULL,
    koin_reward_id integer,
    user_id integer,
    twitter_handle text,
    facebook_handle text,
    linkedin_handle text,
    trigger_status integer,
    fulfill_status character varying(255),
    fulfill_date date,
    coin_id integer,
    amount integer
);


--
-- Name: koin_rewards_fulfills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE koin_rewards_fulfills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: koin_rewards_fulfills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE koin_rewards_fulfills_id_seq OWNED BY koin_rewards_fulfills.id;


--
-- Name: koin_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE koin_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: koin_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE koin_rewards_id_seq OWNED BY koin_rewards.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer,
    dismissed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    contribution_id integer,
    update_id integer,
    origin_email text NOT NULL,
    origin_name text NOT NULL,
    template_name text NOT NULL,
    locale text NOT NULL,
    channel_id integer,
    channel_post_id integer
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: oauth_providers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_providers (
    id integer NOT NULL,
    name text NOT NULL,
    key text NOT NULL,
    secret text NOT NULL,
    scope text,
    "order" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    strategy text,
    path text,
    CONSTRAINT oauth_providers_key_not_blank CHECK ((length(btrim(key)) > 0)),
    CONSTRAINT oauth_providers_name_not_blank CHECK ((length(btrim(name)) > 0)),
    CONSTRAINT oauth_providers_secret_not_blank CHECK ((length(btrim(secret)) > 0))
);


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_providers_id_seq OWNED BY oauth_providers.id;


--
-- Name: payment_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_notifications (
    id integer NOT NULL,
    contribution_id integer NOT NULL,
    extra_data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_notifications_id_seq OWNED BY payment_notifications.id;


--
-- Name: paypal_payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE paypal_payments (
    data text,
    hora text,
    fusohorario text,
    nome text,
    tipo text,
    status text,
    moeda text,
    valorbruto text,
    tarifa text,
    liquido text,
    doe_mail text,
    parae_mail text,
    iddatransacao text,
    statusdoequivalente text,
    statusdoendereco text,
    titulodoitem text,
    iddoitem text,
    valordoenvioemanuseio text,
    valordoseguro text,
    impostosobrevendas text,
    opcao1nome text,
    opcao1valor text,
    opcao2nome text,
    opcao2valor text,
    sitedoleilao text,
    iddocomprador text,
    urldoitem text,
    datadetermino text,
    iddaescritura text,
    iddafatura text,
    "idtxn_dereferência" text,
    numerodafatura text,
    numeropersonalizado text,
    iddorecibo text,
    saldo text,
    enderecolinha1 text,
    enderecolinha2_distrito_bairro text,
    cidade text,
    "estado_regiao_território_prefeitura_republica" text,
    cep text,
    pais text,
    numerodotelefoneparacontato text,
    extra text
);


--
-- Name: project_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_totals AS
 SELECT contributions.project_id,
    sum(contributions.value) AS pledged,
    ((sum(contributions.value) / projects.goal) * (100)::numeric) AS progress,
    sum(contributions.payment_service_fee) AS total_payment_service_fee,
    count(*) AS total_contributions
   FROM (contributions
   JOIN projects ON ((contributions.project_id = projects.id)))
  WHERE ((contributions.state)::text = ANY ((ARRAY['confirmed'::character varying, 'refunded'::character varying, 'requested_refund'::character varying])::text[]))
  GROUP BY contributions.project_id, projects.goal;


--
-- Name: project_financials; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_financials AS
 WITH catarse_fee_percentage AS (
         SELECT (c.value)::numeric AS total,
            ((1)::numeric - (c.value)::numeric) AS complement
           FROM settings c
          WHERE (c.name = 'catarse_fee'::text)
        ), catarse_base_url AS (
         SELECT c.value
           FROM settings c
          WHERE (c.name = 'base_url'::text)
        )
 SELECT p.id AS project_id,
    p.name,
    u.moip_login AS moip,
    p.goal,
    pt.pledged AS reached,
    pt.total_payment_service_fee AS moip_tax,
    (cp.total * pt.pledged) AS catarse_fee,
    (pt.pledged * cp.complement) AS repass_value,
    to_char(expires_at(p.*), 'dd/mm/yyyy'::text) AS expires_at,
    ((catarse_base_url.value || '/admin/reports/contribution_reports.csv?project_id='::text) || p.id) AS contribution_report,
    p.state
   FROM ((((projects p
   JOIN users u ON ((u.id = p.user_id)))
   JOIN project_totals pt ON ((pt.project_id = p.id)))
  CROSS JOIN catarse_fee_percentage cp)
  CROSS JOIN catarse_base_url);


--
-- Name: projects_for_home; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW projects_for_home AS
 WITH recommended_projects AS (
         SELECT 'recommended'::text AS origin,
            recommends.id,
            recommends.name,
            recommends.user_id,
            recommends.category_id,
            recommends.goal,
            recommends.about,
            recommends.headline,
            recommends.video_url,
            recommends.short_url,
            recommends.created_at,
            recommends.updated_at,
            recommends.about_html,
            recommends.recommended,
            recommends.home_page_comment,
            recommends.permalink,
            recommends.video_thumbnail,
            recommends.state,
            recommends.online_days,
            recommends.online_date,
            recommends.how_know,
            recommends.more_links,
            recommends.first_contributions AS first_backers,
            recommends.uploaded_image,
            recommends.video_embed_url
           FROM projects recommends
          WHERE (recommends.recommended AND ((recommends.state)::text = 'online'::text))
          ORDER BY random()
         LIMIT 3
        ), recents_projects AS (
         SELECT 'recents'::text AS origin,
            recents.id,
            recents.name,
            recents.user_id,
            recents.category_id,
            recents.goal,
            recents.about,
            recents.headline,
            recents.video_url,
            recents.short_url,
            recents.created_at,
            recents.updated_at,
            recents.about_html,
            recents.recommended,
            recents.home_page_comment,
            recents.permalink,
            recents.video_thumbnail,
            recents.state,
            recents.online_days,
            recents.online_date,
            recents.how_know,
            recents.more_links,
            recents.first_contributions AS first_backers,
            recents.uploaded_image,
            recents.video_embed_url
           FROM projects recents
          WHERE ((((recents.state)::text = 'online'::text) AND ((now() - recents.online_date) <= '5 days'::interval)) AND (NOT (recents.id IN ( SELECT recommends.id
                   FROM recommended_projects recommends))))
          ORDER BY random()
         LIMIT 3
        ), expiring_projects AS (
         SELECT 'expiring'::text AS origin,
            expiring.id,
            expiring.name,
            expiring.user_id,
            expiring.category_id,
            expiring.goal,
            expiring.about,
            expiring.headline,
            expiring.video_url,
            expiring.short_url,
            expiring.created_at,
            expiring.updated_at,
            expiring.about_html,
            expiring.recommended,
            expiring.home_page_comment,
            expiring.permalink,
            expiring.video_thumbnail,
            expiring.state,
            expiring.online_days,
            expiring.online_date,
            expiring.how_know,
            expiring.more_links,
            expiring.first_contributions AS first_backers,
            expiring.uploaded_image,
            expiring.video_embed_url
           FROM projects expiring
          WHERE ((((expiring.state)::text = 'online'::text) AND (expires_at(expiring.*) <= (now() + '14 days'::interval))) AND (NOT (expiring.id IN (         SELECT recommends.id
                           FROM recommended_projects recommends
                UNION
                         SELECT recents.id
                           FROM recents_projects recents))))
          ORDER BY random()
         LIMIT 3
        )
        (         SELECT recommended_projects.origin,
                    recommended_projects.id,
                    recommended_projects.name,
                    recommended_projects.user_id,
                    recommended_projects.category_id,
                    recommended_projects.goal,
                    recommended_projects.about,
                    recommended_projects.headline,
                    recommended_projects.video_url,
                    recommended_projects.short_url,
                    recommended_projects.created_at,
                    recommended_projects.updated_at,
                    recommended_projects.about_html,
                    recommended_projects.recommended,
                    recommended_projects.home_page_comment,
                    recommended_projects.permalink,
                    recommended_projects.video_thumbnail,
                    recommended_projects.state,
                    recommended_projects.online_days,
                    recommended_projects.online_date,
                    recommended_projects.how_know,
                    recommended_projects.more_links,
                    recommended_projects.first_backers,
                    recommended_projects.uploaded_image,
                    recommended_projects.video_embed_url
                   FROM recommended_projects
        UNION
                 SELECT recents_projects.origin,
                    recents_projects.id,
                    recents_projects.name,
                    recents_projects.user_id,
                    recents_projects.category_id,
                    recents_projects.goal,
                    recents_projects.about,
                    recents_projects.headline,
                    recents_projects.video_url,
                    recents_projects.short_url,
                    recents_projects.created_at,
                    recents_projects.updated_at,
                    recents_projects.about_html,
                    recents_projects.recommended,
                    recents_projects.home_page_comment,
                    recents_projects.permalink,
                    recents_projects.video_thumbnail,
                    recents_projects.state,
                    recents_projects.online_days,
                    recents_projects.online_date,
                    recents_projects.how_know,
                    recents_projects.more_links,
                    recents_projects.first_backers,
                    recents_projects.uploaded_image,
                    recents_projects.video_embed_url
                   FROM recents_projects)
UNION
         SELECT expiring_projects.origin,
            expiring_projects.id,
            expiring_projects.name,
            expiring_projects.user_id,
            expiring_projects.category_id,
            expiring_projects.goal,
            expiring_projects.about,
            expiring_projects.headline,
            expiring_projects.video_url,
            expiring_projects.short_url,
            expiring_projects.created_at,
            expiring_projects.updated_at,
            expiring_projects.about_html,
            expiring_projects.recommended,
            expiring_projects.home_page_comment,
            expiring_projects.permalink,
            expiring_projects.video_thumbnail,
            expiring_projects.state,
            expiring_projects.online_days,
            expiring_projects.online_date,
            expiring_projects.how_know,
            expiring_projects.more_links,
            expiring_projects.first_backers,
            expiring_projects.uploaded_image,
            expiring_projects.video_embed_url
           FROM expiring_projects;


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: projects_in_analysis_by_periods; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW projects_in_analysis_by_periods AS
 WITH weeks AS (
         SELECT to_char(current_year_1.current_year, 'yyyy-mm W'::text) AS current_year,
            to_char(last_year_1.last_year, 'yyyy-mm W'::text) AS last_year,
            current_year_1.current_year AS label
           FROM (generate_series((now() - '49 days'::interval), now(), '7 days'::interval) current_year_1(current_year)
      JOIN generate_series((now() - '1 year 49 days'::interval), (now() - '1 year'::interval), '7 days'::interval) last_year_1(last_year) ON ((to_char(last_year_1.last_year, 'mm W'::text) = to_char(current_year_1.current_year, 'mm W'::text))))
        ), current_year AS (
         SELECT w.label,
            count(*) AS current_year
           FROM (projects p
      JOIN weeks w ON ((w.current_year = to_char(p.sent_to_analysis_at, 'yyyy-mm W'::text))))
     GROUP BY w.label
        ), last_year AS (
         SELECT w.label,
            count(*) AS last_year
           FROM (projects p
      JOIN weeks w ON ((w.last_year = to_char(p.sent_to_analysis_at, 'yyyy-mm W'::text))))
     GROUP BY w.label
        )
 SELECT current_year.label,
    current_year.current_year,
    last_year.last_year
   FROM (current_year
   JOIN last_year USING (label));


--
-- Name: recommendations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW recommendations AS
 SELECT recommendations.user_id,
    recommendations.project_id,
    (sum(recommendations.count))::bigint AS count
   FROM (         SELECT b.user_id,
                    recommendations_1.id AS project_id,
                    count(DISTINCT recommenders.user_id) AS count
                   FROM ((((contributions b
              JOIN projects p ON ((p.id = b.project_id)))
         JOIN contributions backers_same_projects ON ((p.id = backers_same_projects.project_id)))
    JOIN contributions recommenders ON ((recommenders.user_id = backers_same_projects.user_id)))
   JOIN projects recommendations_1 ON ((recommendations_1.id = recommenders.project_id)))
  WHERE ((((((((b.state)::text = 'confirmed'::text) AND ((backers_same_projects.state)::text = 'confirmed'::text)) AND ((recommenders.state)::text = 'confirmed'::text)) AND (b.user_id <> backers_same_projects.user_id)) AND (recommendations_1.id <> b.project_id)) AND ((recommendations_1.state)::text = 'online'::text)) AND (NOT (EXISTS ( SELECT true AS bool
       FROM contributions b2
      WHERE ((((b2.state)::text = 'confirmed'::text) AND (b2.user_id = b.user_id)) AND (b2.project_id = recommendations_1.id))))))
  GROUP BY b.user_id, recommendations_1.id
        UNION
                 SELECT b.user_id,
                    recommendations_1.id AS project_id,
                    0 AS count
                   FROM ((contributions b
              JOIN projects p ON ((b.project_id = p.id)))
         JOIN projects recommendations_1 ON ((recommendations_1.category_id = p.category_id)))
        WHERE (((b.state)::text = 'confirmed'::text) AND ((recommendations_1.state)::text = 'online'::text))) recommendations
  WHERE (NOT (EXISTS ( SELECT true AS bool
           FROM contributions b2
          WHERE ((((b2.state)::text = 'confirmed'::text) AND (b2.user_id = recommendations.user_id)) AND (b2.project_id = recommendations.project_id)))))
  GROUP BY recommendations.user_id, recommendations.project_id
  ORDER BY (sum(recommendations.count))::bigint DESC;


--
-- Name: redeem_records; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE redeem_records (
    id integer NOT NULL,
    amount character varying(255),
    power_quantity double precision,
    date timestamp without time zone,
    account character varying(255),
    options character varying(255),
    usercoin_id integer,
    koin_power_id integer
);


--
-- Name: redeem_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE redeem_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: redeem_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE redeem_records_id_seq OWNED BY redeem_records.id;


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    acronym character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT states_acronym_not_blank CHECK ((length(btrim((acronym)::text)) > 0)),
    CONSTRAINT states_name_not_blank CHECK ((length(btrim((name)::text)) > 0))
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: statistics; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW statistics AS
 SELECT ( SELECT count(*) AS count
           FROM users) AS total_users,
    contributions_totals.total_contributions,
    contributions_totals.total_contributors,
    contributions_totals.total_contributed,
    projects_totals.total_projects,
    projects_totals.total_projects_success,
    projects_totals.total_projects_online
   FROM ( SELECT count(*) AS total_contributions,
            count(DISTINCT contributions.user_id) AS total_contributors,
            sum(contributions.value) AS total_contributed
           FROM contributions
          WHERE ((contributions.state)::text <> ALL (ARRAY[('waiting_confirmation'::character varying)::text, ('pending'::character varying)::text, ('canceled'::character varying)::text, 'deleted'::text]))) contributions_totals,
    ( SELECT count(*) AS total_projects,
            count(
                CASE
                    WHEN ((projects.state)::text = 'successful'::text) THEN 1
                    ELSE NULL::integer
                END) AS total_projects_success,
            count(
                CASE
                    WHEN ((projects.state)::text = 'online'::text) THEN 1
                    ELSE NULL::integer
                END) AS total_projects_online
           FROM projects
          WHERE ((projects.state)::text <> ALL (ARRAY[('draft'::character varying)::text, ('rejected'::character varying)::text]))) projects_totals;


--
-- Name: subscriber_reports; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW subscriber_reports AS
 SELECT u.id,
    cs.channel_id,
    u.name,
    u.email
   FROM (users u
   JOIN channels_subscribers cs ON ((cs.user_id = u.id)));


--
-- Name: total_backed_ranges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE total_backed_ranges (
    name text NOT NULL,
    lower numeric,
    upper numeric
);


--
-- Name: unsubscribes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE unsubscribes (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: unsubscribes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE unsubscribes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unsubscribes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE unsubscribes_id_seq OWNED BY unsubscribes.id;


--
-- Name: updates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE updates (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    title text,
    comment text NOT NULL,
    comment_html text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    exclusive boolean DEFAULT false
);


--
-- Name: updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE updates_id_seq OWNED BY updates.id;


--
-- Name: user_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW user_totals AS
 SELECT b.user_id AS id,
    b.user_id,
    count(DISTINCT b.project_id) AS total_contributed_projects,
    sum(b.value) AS sum,
    count(*) AS count,
    sum(
        CASE
            WHEN (((p.state)::text <> 'failed'::text) AND (NOT b.credits)) THEN (0)::numeric
            WHEN (((p.state)::text = 'failed'::text) AND b.credits) THEN (0)::numeric
            WHEN (((p.state)::text = 'failed'::text) AND ((((b.state)::text = ANY ((ARRAY['requested_refund'::character varying, 'refunded'::character varying])::text[])) AND (NOT b.credits)) OR (b.credits AND (NOT ((b.state)::text = ANY ((ARRAY['requested_refund'::character varying, 'refunded'::character varying])::text[])))))) THEN (0)::numeric
            WHEN ((((p.state)::text = 'failed'::text) AND (NOT b.credits)) AND ((b.state)::text = 'confirmed'::text)) THEN b.value
            ELSE (b.value * ((-1))::numeric)
        END) AS credits
   FROM (contributions b
   JOIN projects p ON ((b.project_id = p.id)))
  WHERE ((b.state)::text = ANY ((ARRAY['confirmed'::character varying, 'requested_refund'::character varying, 'refunded'::character varying])::text[]))
  GROUP BY b.user_id;


--
-- Name: usercoins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE usercoins (
    id integer NOT NULL,
    user_id integer NOT NULL,
    coin_id integer NOT NULL,
    amount numeric(32,16) NOT NULL,
    redeemed_amount numeric(32,16) DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    redeemed_to json
);


--
-- Name: usercoins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE usercoins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usercoins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE usercoins_id_seq OWNED BY usercoins.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations ALTER COLUMN id SET DEFAULT nextval('authorizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_partners ALTER COLUMN id SET DEFAULT nextval('channel_partners_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_posts ALTER COLUMN id SET DEFAULT nextval('channel_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels ALTER COLUMN id SET DEFAULT nextval('channels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_projects ALTER COLUMN id SET DEFAULT nextval('channels_projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_subscribers ALTER COLUMN id SET DEFAULT nextval('channels_subscribers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY coins ALTER COLUMN id SET DEFAULT nextval('coins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions ALTER COLUMN id SET DEFAULT nextval('contributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_features ALTER COLUMN id SET DEFAULT nextval('koin_features_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_powers ALTER COLUMN id SET DEFAULT nextval('koin_powers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_reward_fulfills ALTER COLUMN id SET DEFAULT nextval('koin_reward_fulfills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_rewards ALTER COLUMN id SET DEFAULT nextval('koin_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_rewards_fulfills ALTER COLUMN id SET DEFAULT nextval('koin_rewards_fulfills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_providers ALTER COLUMN id SET DEFAULT nextval('oauth_providers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_notifications ALTER COLUMN id SET DEFAULT nextval('payment_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY redeem_records ALTER COLUMN id SET DEFAULT nextval('redeem_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes ALTER COLUMN id SET DEFAULT nextval('unsubscribes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY updates ALTER COLUMN id SET DEFAULT nextval('updates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY usercoins ALTER COLUMN id SET DEFAULT nextval('usercoins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_pkey PRIMARY KEY (id);


--
-- Name: backers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT backers_pkey PRIMARY KEY (id);


--
-- Name: categories_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_name_unique UNIQUE (name_pt);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: channel_partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channel_partners
    ADD CONSTRAINT channel_partners_pkey PRIMARY KEY (id);


--
-- Name: channel_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channel_posts
    ADD CONSTRAINT channel_posts_pkey PRIMARY KEY (id);


--
-- Name: channel_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels
    ADD CONSTRAINT channel_profiles_pkey PRIMARY KEY (id);


--
-- Name: channels_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT channels_projects_pkey PRIMARY KEY (id);


--
-- Name: channels_subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT channels_subscribers_pkey PRIMARY KEY (id);


--
-- Name: coins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coins
    ADD CONSTRAINT coins_pkey PRIMARY KEY (id);


--
-- Name: configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT configurations_pkey PRIMARY KEY (id);


--
-- Name: koin_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY koin_features
    ADD CONSTRAINT koin_features_pkey PRIMARY KEY (id);


--
-- Name: koin_powers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY koin_powers
    ADD CONSTRAINT koin_powers_pkey PRIMARY KEY (id);


--
-- Name: koin_reward_fulfills_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY koin_reward_fulfills
    ADD CONSTRAINT koin_reward_fulfills_pkey PRIMARY KEY (id);


--
-- Name: koin_rewards_fulfills_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY koin_rewards_fulfills
    ADD CONSTRAINT koin_rewards_fulfills_pkey PRIMARY KEY (id);


--
-- Name: koin_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY koin_rewards
    ADD CONSTRAINT koin_rewards_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_providers_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_providers
    ADD CONSTRAINT oauth_providers_name_unique UNIQUE (name);


--
-- Name: oauth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_providers
    ADD CONSTRAINT oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: payment_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT payment_notifications_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: redeem_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY redeem_records
    ADD CONSTRAINT redeem_records_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: states_acronym_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_acronym_unique UNIQUE (acronym);


--
-- Name: states_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_name_unique UNIQUE (name);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: total_backed_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY total_backed_ranges
    ADD CONSTRAINT total_backed_ranges_pkey PRIMARY KEY (name);


--
-- Name: unsubscribes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_pkey PRIMARY KEY (id);


--
-- Name: updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_pkey PRIMARY KEY (id);


--
-- Name: usercoins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY usercoins
    ADD CONSTRAINT usercoins_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: fk__authorizations_oauth_provider_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__authorizations_oauth_provider_id ON authorizations USING btree (oauth_provider_id);


--
-- Name: fk__authorizations_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__authorizations_user_id ON authorizations USING btree (user_id);


--
-- Name: fk__channel_partners_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channel_partners_channel_id ON channel_partners USING btree (channel_id);


--
-- Name: fk__channel_posts_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channel_posts_channel_id ON channel_posts USING btree (channel_id);


--
-- Name: fk__channel_posts_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channel_posts_user_id ON channel_posts USING btree (user_id);


--
-- Name: fk__channels_subscribers_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channels_subscribers_channel_id ON channels_subscribers USING btree (channel_id);


--
-- Name: fk__channels_subscribers_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channels_subscribers_user_id ON channels_subscribers USING btree (user_id);


--
-- Name: fk__coins_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__coins_project_id ON coins USING btree (project_id);


--
-- Name: fk__coins_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__coins_user_id ON coins USING btree (user_id);


--
-- Name: fk__koin_features_coin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__koin_features_coin_id ON koin_features USING btree (coin_id);


--
-- Name: fk__koin_powers_coin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__koin_powers_coin_id ON koin_powers USING btree (coin_id);


--
-- Name: fk__koin_reward_fulfills_koin_reward_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__koin_reward_fulfills_koin_reward_id ON koin_reward_fulfills USING btree (koin_reward_id);


--
-- Name: fk__koin_reward_fulfills_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__koin_reward_fulfills_user_id ON koin_reward_fulfills USING btree (user_id);


--
-- Name: fk__koin_rewards_coin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__koin_rewards_coin_id ON koin_rewards USING btree (coin_id);


--
-- Name: fk__koin_rewards_fulfills_coin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__koin_rewards_fulfills_coin_id ON koin_rewards_fulfills USING btree (coin_id);


--
-- Name: fk__koin_rewards_fulfills_koin_reward_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__koin_rewards_fulfills_koin_reward_id ON koin_rewards_fulfills USING btree (koin_reward_id);


--
-- Name: fk__koin_rewards_fulfills_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__koin_rewards_fulfills_user_id ON koin_rewards_fulfills USING btree (user_id);


--
-- Name: fk__notifications_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__notifications_channel_id ON notifications USING btree (channel_id);


--
-- Name: fk__notifications_channel_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__notifications_channel_post_id ON notifications USING btree (channel_post_id);


--
-- Name: fk__redeem_records_koin_power_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__redeem_records_koin_power_id ON redeem_records USING btree (koin_power_id);


--
-- Name: fk__redeem_records_usercoin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__redeem_records_usercoin_id ON redeem_records USING btree (usercoin_id);


--
-- Name: fk__usercoins_coin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__usercoins_coin_id ON usercoins USING btree (coin_id);


--
-- Name: fk__usercoins_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__usercoins_user_id ON usercoins USING btree (user_id);


--
-- Name: fk__users_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__users_channel_id ON users USING btree (channel_id);


--
-- Name: index_authorizations_on_oauth_provider_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_authorizations_on_oauth_provider_id_and_user_id ON authorizations USING btree (oauth_provider_id, user_id);


--
-- Name: index_authorizations_on_uid_and_oauth_provider_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_authorizations_on_uid_and_oauth_provider_id ON authorizations USING btree (uid, oauth_provider_id);


--
-- Name: index_categories_on_name_pt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_name_pt ON categories USING btree (name_pt);


--
-- Name: index_channel_posts_on_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_channel_posts_on_channel_id ON channel_posts USING btree (channel_id);


--
-- Name: index_channel_posts_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_channel_posts_on_user_id ON channel_posts USING btree (user_id);


--
-- Name: index_channels_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_on_permalink ON channels USING btree (permalink);


--
-- Name: index_channels_projects_on_channel_id_and_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_projects_on_channel_id_and_project_id ON channels_projects USING btree (channel_id, project_id);


--
-- Name: index_channels_projects_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_channels_projects_on_project_id ON channels_projects USING btree (project_id);


--
-- Name: index_channels_subscribers_on_user_id_and_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_subscribers_on_user_id_and_channel_id ON channels_subscribers USING btree (user_id, channel_id);


--
-- Name: index_coins_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coins_on_project_id ON coins USING btree (project_id);


--
-- Name: index_coins_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coins_on_user_id ON coins USING btree (user_id);


--
-- Name: index_configurations_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_configurations_on_name ON settings USING btree (name);


--
-- Name: index_contributions_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_key ON contributions USING btree (key);


--
-- Name: index_contributions_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_project_id ON contributions USING btree (project_id);


--
-- Name: index_contributions_on_reward_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_reward_id ON contributions USING btree (reward_id);


--
-- Name: index_contributions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_user_id ON contributions USING btree (user_id);


--
-- Name: index_notifications_on_contribution_id_and_template_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_contribution_id_and_template_name ON notifications USING btree (contribution_id, template_name);


--
-- Name: index_notifications_on_project_id_and_template_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_project_id_and_template_name ON notifications USING btree (project_id, template_name);


--
-- Name: index_notifications_on_update_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_update_id ON notifications USING btree (update_id);


--
-- Name: index_notifications_on_user_id_and_template_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_user_id_and_template_name ON notifications USING btree (user_id, template_name);


--
-- Name: index_payment_notifications_on_contribution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payment_notifications_on_contribution_id ON payment_notifications USING btree (contribution_id);


--
-- Name: index_projects_on_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_category_id ON projects USING btree (category_id);


--
-- Name: index_projects_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_name ON projects USING btree (name);


--
-- Name: index_projects_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_permalink ON projects USING btree (lower(permalink));


--
-- Name: index_projects_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_user_id ON projects USING btree (user_id);


--
-- Name: index_rewards_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rewards_on_project_id ON rewards USING btree (project_id);


--
-- Name: index_unsubscribes_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_project_id ON unsubscribes USING btree (project_id);


--
-- Name: index_unsubscribes_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_user_id ON unsubscribes USING btree (user_id);


--
-- Name: index_updates_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_updates_on_project_id ON updates USING btree (project_id);


--
-- Name: index_usercoins_on_coin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_usercoins_on_coin_id ON usercoins USING btree (coin_id);


--
-- Name: index_usercoins_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_usercoins_on_user_id ON usercoins USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_name ON users USING btree (name);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: contributions_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: contributions_reward_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_reward_id_reference FOREIGN KEY (reward_id) REFERENCES rewards(id);


--
-- Name: contributions_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_authorizations_oauth_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT fk_authorizations_oauth_provider_id FOREIGN KEY (oauth_provider_id) REFERENCES oauth_providers(id);


--
-- Name: fk_authorizations_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT fk_authorizations_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_channel_partners_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_partners
    ADD CONSTRAINT fk_channel_partners_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channel_posts_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_posts
    ADD CONSTRAINT fk_channel_posts_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channel_posts_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_posts
    ADD CONSTRAINT fk_channel_posts_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_channels_projects_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT fk_channels_projects_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channels_projects_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT fk_channels_projects_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_channels_subscribers_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT fk_channels_subscribers_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channels_subscribers_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT fk_channels_subscribers_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_coins_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY coins
    ADD CONSTRAINT fk_coins_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_coins_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY coins
    ADD CONSTRAINT fk_coins_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_koin_features_coin_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_features
    ADD CONSTRAINT fk_koin_features_coin_id FOREIGN KEY (coin_id) REFERENCES coins(id);


--
-- Name: fk_koin_powers_coin_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_powers
    ADD CONSTRAINT fk_koin_powers_coin_id FOREIGN KEY (coin_id) REFERENCES coins(id);


--
-- Name: fk_koin_reward_fulfills_koin_reward_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_reward_fulfills
    ADD CONSTRAINT fk_koin_reward_fulfills_koin_reward_id FOREIGN KEY (koin_reward_id) REFERENCES koin_rewards(id);


--
-- Name: fk_koin_reward_fulfills_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_reward_fulfills
    ADD CONSTRAINT fk_koin_reward_fulfills_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_koin_rewards_coin_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_rewards
    ADD CONSTRAINT fk_koin_rewards_coin_id FOREIGN KEY (coin_id) REFERENCES coins(id);


--
-- Name: fk_koin_rewards_fulfills_coin_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_rewards_fulfills
    ADD CONSTRAINT fk_koin_rewards_fulfills_coin_id FOREIGN KEY (coin_id) REFERENCES coins(id);


--
-- Name: fk_koin_rewards_fulfills_koin_reward_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_rewards_fulfills
    ADD CONSTRAINT fk_koin_rewards_fulfills_koin_reward_id FOREIGN KEY (koin_reward_id) REFERENCES koin_rewards(id);


--
-- Name: fk_koin_rewards_fulfills_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY koin_rewards_fulfills
    ADD CONSTRAINT fk_koin_rewards_fulfills_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_notifications_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_notifications_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_notifications_channel_post_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_notifications_channel_post_id FOREIGN KEY (channel_post_id) REFERENCES channel_posts(id);


--
-- Name: fk_redeem_records_koin_power_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY redeem_records
    ADD CONSTRAINT fk_redeem_records_koin_power_id FOREIGN KEY (koin_power_id) REFERENCES koin_powers(id);


--
-- Name: fk_redeem_records_usercoin_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY redeem_records
    ADD CONSTRAINT fk_redeem_records_usercoin_id FOREIGN KEY (usercoin_id) REFERENCES usercoins(id);


--
-- Name: fk_usercoins_coin_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY usercoins
    ADD CONSTRAINT fk_usercoins_coin_id FOREIGN KEY (coin_id) REFERENCES coins(id);


--
-- Name: fk_usercoins_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY usercoins
    ADD CONSTRAINT fk_usercoins_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_users_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: notifications_backer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_backer_id_fk FOREIGN KEY (contribution_id) REFERENCES contributions(id);


--
-- Name: notifications_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: notifications_update_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_update_id_fk FOREIGN KEY (update_id) REFERENCES updates(id);


--
-- Name: notifications_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: payment_notifications_backer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT payment_notifications_backer_id_fk FOREIGN KEY (contribution_id) REFERENCES contributions(id);


--
-- Name: projects_category_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_category_id_reference FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: projects_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: rewards_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: unsubscribes_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: unsubscribes_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: updates_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: updates_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20121226120921');

INSERT INTO schema_migrations (version) VALUES ('20121227012003');

INSERT INTO schema_migrations (version) VALUES ('20121227012324');

INSERT INTO schema_migrations (version) VALUES ('20121230111351');

INSERT INTO schema_migrations (version) VALUES ('20130102180139');

INSERT INTO schema_migrations (version) VALUES ('20130104005632');

INSERT INTO schema_migrations (version) VALUES ('20130104104501');

INSERT INTO schema_migrations (version) VALUES ('20130105123546');

INSERT INTO schema_migrations (version) VALUES ('20130110191750');

INSERT INTO schema_migrations (version) VALUES ('20130117205659');

INSERT INTO schema_migrations (version) VALUES ('20130118193907');

INSERT INTO schema_migrations (version) VALUES ('20130121162447');

INSERT INTO schema_migrations (version) VALUES ('20130121204224');

INSERT INTO schema_migrations (version) VALUES ('20130121212325');

INSERT INTO schema_migrations (version) VALUES ('20130131121553');

INSERT INTO schema_migrations (version) VALUES ('20130201200604');

INSERT INTO schema_migrations (version) VALUES ('20130201202648');

INSERT INTO schema_migrations (version) VALUES ('20130201202829');

INSERT INTO schema_migrations (version) VALUES ('20130201205659');

INSERT INTO schema_migrations (version) VALUES ('20130204192704');

INSERT INTO schema_migrations (version) VALUES ('20130205143533');

INSERT INTO schema_migrations (version) VALUES ('20130206121758');

INSERT INTO schema_migrations (version) VALUES ('20130211174609');

INSERT INTO schema_migrations (version) VALUES ('20130212145115');

INSERT INTO schema_migrations (version) VALUES ('20130213184141');

INSERT INTO schema_migrations (version) VALUES ('20130218201312');

INSERT INTO schema_migrations (version) VALUES ('20130218201751');

INSERT INTO schema_migrations (version) VALUES ('20130221171018');

INSERT INTO schema_migrations (version) VALUES ('20130221172840');

INSERT INTO schema_migrations (version) VALUES ('20130221175717');

INSERT INTO schema_migrations (version) VALUES ('20130221184144');

INSERT INTO schema_migrations (version) VALUES ('20130221185532');

INSERT INTO schema_migrations (version) VALUES ('20130221201732');

INSERT INTO schema_migrations (version) VALUES ('20130222163633');

INSERT INTO schema_migrations (version) VALUES ('20130225135512');

INSERT INTO schema_migrations (version) VALUES ('20130225141802');

INSERT INTO schema_migrations (version) VALUES ('20130228141234');

INSERT INTO schema_migrations (version) VALUES ('20130304193806');

INSERT INTO schema_migrations (version) VALUES ('20130307074614');

INSERT INTO schema_migrations (version) VALUES ('20130307090153');

INSERT INTO schema_migrations (version) VALUES ('20130308200907');

INSERT INTO schema_migrations (version) VALUES ('20130311191444');

INSERT INTO schema_migrations (version) VALUES ('20130311192846');

INSERT INTO schema_migrations (version) VALUES ('20130312001021');

INSERT INTO schema_migrations (version) VALUES ('20130313032607');

INSERT INTO schema_migrations (version) VALUES ('20130313034356');

INSERT INTO schema_migrations (version) VALUES ('20130319131919');

INSERT INTO schema_migrations (version) VALUES ('20130410181958');

INSERT INTO schema_migrations (version) VALUES ('20130410190247');

INSERT INTO schema_migrations (version) VALUES ('20130410191240');

INSERT INTO schema_migrations (version) VALUES ('20130411193016');

INSERT INTO schema_migrations (version) VALUES ('20130419184530');

INSERT INTO schema_migrations (version) VALUES ('20130422071805');

INSERT INTO schema_migrations (version) VALUES ('20130422072051');

INSERT INTO schema_migrations (version) VALUES ('20130423162359');

INSERT INTO schema_migrations (version) VALUES ('20130424173128');

INSERT INTO schema_migrations (version) VALUES ('20130426204503');

INSERT INTO schema_migrations (version) VALUES ('20130429142823');

INSERT INTO schema_migrations (version) VALUES ('20130429144749');

INSERT INTO schema_migrations (version) VALUES ('20130429153115');

INSERT INTO schema_migrations (version) VALUES ('20130430203333');

INSERT INTO schema_migrations (version) VALUES ('20130502175814');

INSERT INTO schema_migrations (version) VALUES ('20130505013655');

INSERT INTO schema_migrations (version) VALUES ('20130506191243');

INSERT INTO schema_migrations (version) VALUES ('20130506191508');

INSERT INTO schema_migrations (version) VALUES ('20130514132519');

INSERT INTO schema_migrations (version) VALUES ('20130514185010');

INSERT INTO schema_migrations (version) VALUES ('20130514185116');

INSERT INTO schema_migrations (version) VALUES ('20130514185926');

INSERT INTO schema_migrations (version) VALUES ('20130515192404');

INSERT INTO schema_migrations (version) VALUES ('20130523144013');

INSERT INTO schema_migrations (version) VALUES ('20130523173609');

INSERT INTO schema_migrations (version) VALUES ('20130527204639');

INSERT INTO schema_migrations (version) VALUES ('20130529171845');

INSERT INTO schema_migrations (version) VALUES ('20130604171730');

INSERT INTO schema_migrations (version) VALUES ('20130604172253');

INSERT INTO schema_migrations (version) VALUES ('20130604175953');

INSERT INTO schema_migrations (version) VALUES ('20130604180503');

INSERT INTO schema_migrations (version) VALUES ('20130607222330');

INSERT INTO schema_migrations (version) VALUES ('20130617175402');

INSERT INTO schema_migrations (version) VALUES ('20130618175432');

INSERT INTO schema_migrations (version) VALUES ('20130626122439');

INSERT INTO schema_migrations (version) VALUES ('20130626124055');

INSERT INTO schema_migrations (version) VALUES ('20130702192659');

INSERT INTO schema_migrations (version) VALUES ('20130703171547');

INSERT INTO schema_migrations (version) VALUES ('20130705131825');

INSERT INTO schema_migrations (version) VALUES ('20130705184845');

INSERT INTO schema_migrations (version) VALUES ('20130710122804');

INSERT INTO schema_migrations (version) VALUES ('20130722222945');

INSERT INTO schema_migrations (version) VALUES ('20130730232043');

INSERT INTO schema_migrations (version) VALUES ('20130805230126');

INSERT INTO schema_migrations (version) VALUES ('20130812191450');

INSERT INTO schema_migrations (version) VALUES ('20130814174329');

INSERT INTO schema_migrations (version) VALUES ('20130815161926');

INSERT INTO schema_migrations (version) VALUES ('20130818015857');

INSERT INTO schema_migrations (version) VALUES ('20130822215532');

INSERT INTO schema_migrations (version) VALUES ('20130827210414');

INSERT INTO schema_migrations (version) VALUES ('20130828160026');

INSERT INTO schema_migrations (version) VALUES ('20130829180232');

INSERT INTO schema_migrations (version) VALUES ('20130905153553');

INSERT INTO schema_migrations (version) VALUES ('20130911180657');

INSERT INTO schema_migrations (version) VALUES ('20130918191809');

INSERT INTO schema_migrations (version) VALUES ('20130926185207');

INSERT INTO schema_migrations (version) VALUES ('20131008190648');

INSERT INTO schema_migrations (version) VALUES ('20131010193936');

INSERT INTO schema_migrations (version) VALUES ('20131010194006');

INSERT INTO schema_migrations (version) VALUES ('20131010194345');

INSERT INTO schema_migrations (version) VALUES ('20131010194500');

INSERT INTO schema_migrations (version) VALUES ('20131010194521');

INSERT INTO schema_migrations (version) VALUES ('20131014201229');

INSERT INTO schema_migrations (version) VALUES ('20131016193346');

INSERT INTO schema_migrations (version) VALUES ('20131016214955');

INSERT INTO schema_migrations (version) VALUES ('20131016231130');

INSERT INTO schema_migrations (version) VALUES ('20131018170211');

INSERT INTO schema_migrations (version) VALUES ('20131020215932');

INSERT INTO schema_migrations (version) VALUES ('20131021190108');

INSERT INTO schema_migrations (version) VALUES ('20131022154220');

INSERT INTO schema_migrations (version) VALUES ('20131023031539');

INSERT INTO schema_migrations (version) VALUES ('20131023032325');

INSERT INTO schema_migrations (version) VALUES ('20131107143439');

INSERT INTO schema_migrations (version) VALUES ('20131107143512');

INSERT INTO schema_migrations (version) VALUES ('20131107143537');

INSERT INTO schema_migrations (version) VALUES ('20131107143832');

INSERT INTO schema_migrations (version) VALUES ('20131107145351');

INSERT INTO schema_migrations (version) VALUES ('20131107161918');

INSERT INTO schema_migrations (version) VALUES ('20131112113608');

INSERT INTO schema_migrations (version) VALUES ('20131113145601');

INSERT INTO schema_migrations (version) VALUES ('20131114154112');

INSERT INTO schema_migrations (version) VALUES ('20131127132159');

INSERT INTO schema_migrations (version) VALUES ('20131128142533');

INSERT INTO schema_migrations (version) VALUES ('20131230171126');

INSERT INTO schema_migrations (version) VALUES ('20131230172840');

INSERT INTO schema_migrations (version) VALUES ('20140102125037');

INSERT INTO schema_migrations (version) VALUES ('20140115110512');

INSERT INTO schema_migrations (version) VALUES ('20140117115326');

INSERT INTO schema_migrations (version) VALUES ('20140120195335');

INSERT INTO schema_migrations (version) VALUES ('20140120201216');

INSERT INTO schema_migrations (version) VALUES ('20140121114718');

INSERT INTO schema_migrations (version) VALUES ('20140121124230');

INSERT INTO schema_migrations (version) VALUES ('20140121124646');

INSERT INTO schema_migrations (version) VALUES ('20140121124840');

INSERT INTO schema_migrations (version) VALUES ('20140121125256');

INSERT INTO schema_migrations (version) VALUES ('20140121130341');

INSERT INTO schema_migrations (version) VALUES ('20140121171044');

INSERT INTO schema_migrations (version) VALUES ('20140207160934');

INSERT INTO schema_migrations (version) VALUES ('20140210233516');

INSERT INTO schema_migrations (version) VALUES ('20140219192513');

INSERT INTO schema_migrations (version) VALUES ('20140219192658');

INSERT INTO schema_migrations (version) VALUES ('20140310200601');

INSERT INTO schema_migrations (version) VALUES ('20140310201238');

INSERT INTO schema_migrations (version) VALUES ('20140319121007');

INSERT INTO schema_migrations (version) VALUES ('20140325150844');

INSERT INTO schema_migrations (version) VALUES ('20140331204618');

INSERT INTO schema_migrations (version) VALUES ('20140331215022');

INSERT INTO schema_migrations (version) VALUES ('20140401144727');

INSERT INTO schema_migrations (version) VALUES ('20140401145136');

INSERT INTO schema_migrations (version) VALUES ('20140410175400');

INSERT INTO schema_migrations (version) VALUES ('20140410184603');

INSERT INTO schema_migrations (version) VALUES ('20140414164640');

INSERT INTO schema_migrations (version) VALUES ('20140424171245');

INSERT INTO schema_migrations (version) VALUES ('20140502192210');

INSERT INTO schema_migrations (version) VALUES ('20140506011533');

INSERT INTO schema_migrations (version) VALUES ('20140506152503');

INSERT INTO schema_migrations (version) VALUES ('20140514125258');

INSERT INTO schema_migrations (version) VALUES ('20140601183655');

INSERT INTO schema_migrations (version) VALUES ('20140602010640');

INSERT INTO schema_migrations (version) VALUES ('20140605042720');

INSERT INTO schema_migrations (version) VALUES ('20140608191311');

INSERT INTO schema_migrations (version) VALUES ('20140608195115');

INSERT INTO schema_migrations (version) VALUES ('20140610032104');

INSERT INTO schema_migrations (version) VALUES ('20140610040437');

INSERT INTO schema_migrations (version) VALUES ('20140610043851');

INSERT INTO schema_migrations (version) VALUES ('20140613171823');

INSERT INTO schema_migrations (version) VALUES ('20140614065940');

INSERT INTO schema_migrations (version) VALUES ('20140614070028');

INSERT INTO schema_migrations (version) VALUES ('20140614072829');

INSERT INTO schema_migrations (version) VALUES ('20140614212029');

INSERT INTO schema_migrations (version) VALUES ('20140614212333');

INSERT INTO schema_migrations (version) VALUES ('20140615011808');

INSERT INTO schema_migrations (version) VALUES ('20140615011912');

INSERT INTO schema_migrations (version) VALUES ('20140615012048');

INSERT INTO schema_migrations (version) VALUES ('20140615012358');

INSERT INTO schema_migrations (version) VALUES ('20140615014658');

INSERT INTO schema_migrations (version) VALUES ('20140615014834');

INSERT INTO schema_migrations (version) VALUES ('20140615014851');

INSERT INTO schema_migrations (version) VALUES ('20140616190952');

INSERT INTO schema_migrations (version) VALUES ('20140616191606');

INSERT INTO schema_migrations (version) VALUES ('20140616193006');

INSERT INTO schema_migrations (version) VALUES ('20140617052204');

INSERT INTO schema_migrations (version) VALUES ('20140617052345');

INSERT INTO schema_migrations (version) VALUES ('20140617080041');

INSERT INTO schema_migrations (version) VALUES ('20140707181550');

INSERT INTO schema_migrations (version) VALUES ('20140707195054');
