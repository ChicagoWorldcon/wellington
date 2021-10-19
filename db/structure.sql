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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    field_1 character varying DEFAULT 'Nomination'::character varying NOT NULL,
    field_2 character varying,
    field_3 character varying,
    election_id bigint NOT NULL,
    "order" integer
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.charges (
    id bigint NOT NULL,
    stripe_response json,
    comment character varying NOT NULL,
    state character varying NOT NULL,
    stripe_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL,
    reservation_id bigint NOT NULL,
    transfer character varying NOT NULL,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying DEFAULT 'USD'::character varying NOT NULL
);


--
-- Name: charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.charges_id_seq OWNED BY public.charges.id;


--
-- Name: chicago_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chicago_contacts (
    id bigint NOT NULL,
    claim_id bigint NOT NULL,
    import_key character varying,
    title character varying,
    first_name character varying,
    last_name character varying,
    preferred_first_name character varying,
    preferred_last_name character varying,
    badge_subtitle character varying,
    badge_title character varying,
    address_line_1 character varying,
    address_line_2 character varying,
    city character varying,
    country character varying,
    postal character varying,
    province character varying,
    publication_format character varying,
    interest_accessibility_services boolean,
    interest_being_on_program boolean,
    interest_dealers boolean,
    interest_exhibiting boolean,
    interest_performing boolean,
    interest_selling_at_art_show boolean,
    interest_volunteering boolean,
    share_with_future_worldcons boolean DEFAULT true,
    show_in_listings boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mail_souvenir_book boolean,
    date_of_birth date,
    email character varying,
    installment_wanted boolean DEFAULT false NOT NULL
);


--
-- Name: chicago_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chicago_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chicago_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chicago_contacts_id_seq OWNED BY public.chicago_contacts.id;


--
-- Name: claims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.claims (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    reservation_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active_from timestamp without time zone NOT NULL,
    active_to timestamp without time zone
);


--
-- Name: claims_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.claims_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.claims_id_seq OWNED BY public.claims.id;


--
-- Name: conzealand_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conzealand_contacts (
    id bigint NOT NULL,
    claim_id bigint NOT NULL,
    import_key character varying,
    first_name character varying,
    preferred_first_name character varying,
    preferred_last_name character varying,
    badge_title character varying,
    badge_subtitle character varying,
    address_line_1 character varying,
    address_line_2 character varying,
    city character varying,
    province character varying,
    postal character varying,
    country character varying,
    publication_format character varying,
    show_in_listings boolean DEFAULT true,
    share_with_future_worldcons boolean DEFAULT true,
    interest_volunteering boolean,
    interest_accessibility_services boolean,
    interest_being_on_program boolean,
    interest_dealers boolean,
    interest_selling_at_art_show boolean,
    interest_exhibiting boolean,
    interest_performing boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying,
    last_name character varying
);


--
-- Name: conzealand_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conzealand_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conzealand_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conzealand_contacts_id_seq OWNED BY public.conzealand_contacts.id;


--
-- Name: dc_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dc_contacts (
    id bigint NOT NULL,
    claim_id bigint NOT NULL,
    import_key character varying,
    title character varying,
    first_name character varying,
    last_name character varying,
    preferred_first_name character varying,
    preferred_last_name character varying,
    badge_subtitle character varying,
    badge_title character varying,
    address_line_1 character varying,
    address_line_2 character varying,
    city character varying,
    country character varying,
    postal character varying,
    province character varying,
    publication_format character varying,
    interest_accessibility_services boolean,
    interest_being_on_program boolean,
    interest_dealers boolean,
    interest_exhibiting boolean,
    interest_performing boolean,
    interest_selling_at_art_show boolean,
    interest_volunteering boolean,
    share_with_future_worldcons boolean DEFAULT true,
    show_in_listings boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    covid boolean
);


--
-- Name: dc_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dc_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dc_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dc_contacts_id_seq OWNED BY public.dc_contacts.id;


--
-- Name: elections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.elections (
    id bigint NOT NULL,
    name character varying NOT NULL,
    i18n_key character varying DEFAULT 'hugo'::character varying NOT NULL
);


--
-- Name: elections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.elections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: elections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.elections_id_seq OWNED BY public.elections.id;


--
-- Name: finalists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.finalists (
    id bigint NOT NULL,
    category_id bigint NOT NULL,
    description character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: finalists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.finalists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: finalists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.finalists_id_seq OWNED BY public.finalists.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id bigint NOT NULL,
    name character varying NOT NULL,
    active_from timestamp without time zone NOT NULL,
    active_to timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description character varying,
    can_vote boolean DEFAULT false NOT NULL,
    can_attend boolean DEFAULT false NOT NULL,
    price_cents integer DEFAULT 0 NOT NULL,
    price_currency character varying DEFAULT 'USD'::character varying NOT NULL,
    can_nominate boolean DEFAULT false NOT NULL,
    can_site_select boolean DEFAULT false NOT NULL,
    dob_required boolean DEFAULT false NOT NULL,
    display_name character varying
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: nominations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nominations (
    id bigint NOT NULL,
    category_id bigint NOT NULL,
    reservation_id bigint NOT NULL,
    field_1 character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    field_2 character varying,
    field_3 character varying
);


--
-- Name: nominations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nominations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nominations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nominations_id_seq OWNED BY public.nominations.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    content character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id bigint NOT NULL,
    reservation_id bigint NOT NULL,
    membership_id bigint NOT NULL,
    active_from timestamp without time zone NOT NULL,
    active_to timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: ranks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ranks (
    id bigint NOT NULL,
    finalist_id bigint NOT NULL,
    reservation_id bigint NOT NULL,
    "position" integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ranks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ranks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ranks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ranks_id_seq OWNED BY public.ranks.id;


--
-- Name: reservations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reservations (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying NOT NULL,
    membership_number integer NOT NULL,
    ballot_last_mailed_at timestamp without time zone
);


--
-- Name: reservations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reservations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reservations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reservations_id_seq OWNED BY public.reservations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: supports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supports (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hugo_admin boolean DEFAULT false NOT NULL
);


--
-- Name: supports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.supports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.supports_id_seq OWNED BY public.supports.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    stripe_id character varying,
    hugo_download_counter integer DEFAULT 0 NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges ALTER COLUMN id SET DEFAULT nextval('public.charges_id_seq'::regclass);


--
-- Name: chicago_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chicago_contacts ALTER COLUMN id SET DEFAULT nextval('public.chicago_contacts_id_seq'::regclass);


--
-- Name: claims id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claims ALTER COLUMN id SET DEFAULT nextval('public.claims_id_seq'::regclass);


--
-- Name: conzealand_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conzealand_contacts ALTER COLUMN id SET DEFAULT nextval('public.conzealand_contacts_id_seq'::regclass);


--
-- Name: dc_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dc_contacts ALTER COLUMN id SET DEFAULT nextval('public.dc_contacts_id_seq'::regclass);


--
-- Name: elections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elections ALTER COLUMN id SET DEFAULT nextval('public.elections_id_seq'::regclass);


--
-- Name: finalists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finalists ALTER COLUMN id SET DEFAULT nextval('public.finalists_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: nominations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nominations ALTER COLUMN id SET DEFAULT nextval('public.nominations_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: ranks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ranks ALTER COLUMN id SET DEFAULT nextval('public.ranks_id_seq'::regclass);


--
-- Name: reservations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservations ALTER COLUMN id SET DEFAULT nextval('public.reservations_id_seq'::regclass);


--
-- Name: supports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supports ALTER COLUMN id SET DEFAULT nextval('public.supports_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: charges charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges
    ADD CONSTRAINT charges_pkey PRIMARY KEY (id);


--
-- Name: chicago_contacts chicago_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chicago_contacts
    ADD CONSTRAINT chicago_contacts_pkey PRIMARY KEY (id);


--
-- Name: claims claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT claims_pkey PRIMARY KEY (id);


--
-- Name: conzealand_contacts conzealand_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conzealand_contacts
    ADD CONSTRAINT conzealand_contacts_pkey PRIMARY KEY (id);


--
-- Name: dc_contacts dc_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dc_contacts
    ADD CONSTRAINT dc_contacts_pkey PRIMARY KEY (id);


--
-- Name: elections elections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elections
    ADD CONSTRAINT elections_pkey PRIMARY KEY (id);


--
-- Name: finalists finalists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finalists
    ADD CONSTRAINT finalists_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: nominations nominations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nominations
    ADD CONSTRAINT nominations_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: ranks ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (id);


--
-- Name: reservations reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: supports supports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supports
    ADD CONSTRAINT supports_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_categories_on_election_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_election_id ON public.categories USING btree (election_id);


--
-- Name: index_categories_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_name ON public.categories USING btree (name);


--
-- Name: index_charges_on_reservation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_reservation_id ON public.charges USING btree (reservation_id);


--
-- Name: index_charges_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_user_id ON public.charges USING btree (user_id);


--
-- Name: index_chicago_contacts_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chicago_contacts_on_claim_id ON public.chicago_contacts USING btree (claim_id);


--
-- Name: index_claims_on_reservation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claims_on_reservation_id ON public.claims USING btree (reservation_id);


--
-- Name: index_claims_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claims_on_user_id ON public.claims USING btree (user_id);


--
-- Name: index_conzealand_contacts_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conzealand_contacts_on_claim_id ON public.conzealand_contacts USING btree (claim_id);


--
-- Name: index_dc_contacts_on_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dc_contacts_on_claim_id ON public.dc_contacts USING btree (claim_id);


--
-- Name: index_elections_on_i18n_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_elections_on_i18n_key ON public.elections USING btree (i18n_key);


--
-- Name: index_finalists_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_finalists_on_category_id ON public.finalists USING btree (category_id);


--
-- Name: index_nominations_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_nominations_on_category_id ON public.nominations USING btree (category_id);


--
-- Name: index_nominations_on_reservation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_nominations_on_reservation_id ON public.nominations USING btree (reservation_id);


--
-- Name: index_notes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_user_id ON public.notes USING btree (user_id);


--
-- Name: index_orders_on_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_membership_id ON public.orders USING btree (membership_id);


--
-- Name: index_orders_on_reservation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_reservation_id ON public.orders USING btree (reservation_id);


--
-- Name: index_ranks_on_finalist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ranks_on_finalist_id ON public.ranks USING btree (finalist_id);


--
-- Name: index_ranks_on_reservation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ranks_on_reservation_id ON public.ranks USING btree (reservation_id);


--
-- Name: index_reservations_on_membership_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_reservations_on_membership_number ON public.reservations USING btree (membership_number);


--
-- Name: index_supports_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_supports_on_confirmation_token ON public.supports USING btree (confirmation_token);


--
-- Name: index_supports_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_supports_on_email ON public.supports USING btree (email);


--
-- Name: index_supports_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_supports_on_reset_password_token ON public.supports USING btree (reset_password_token);


--
-- Name: index_supports_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_supports_on_unlock_token ON public.supports USING btree (unlock_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: nominations fk_rails_1724df02dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nominations
    ADD CONSTRAINT fk_rails_1724df02dc FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: ranks fk_rails_23cee67c32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ranks
    ADD CONSTRAINT fk_rails_23cee67c32 FOREIGN KEY (finalist_id) REFERENCES public.finalists(id);


--
-- Name: nominations fk_rails_31eec2b75d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nominations
    ADD CONSTRAINT fk_rails_31eec2b75d FOREIGN KEY (reservation_id) REFERENCES public.reservations(id);


--
-- Name: claims fk_rails_35cad80142; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT fk_rails_35cad80142 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: categories fk_rails_4520a4c84e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_rails_4520a4c84e FOREIGN KEY (election_id) REFERENCES public.elections(id);


--
-- Name: orders fk_rails_4b32829485; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_4b32829485 FOREIGN KEY (reservation_id) REFERENCES public.reservations(id);


--
-- Name: charges fk_rails_534454e0f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges
    ADD CONSTRAINT fk_rails_534454e0f6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: charges fk_rails_5cd975e78e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges
    ADD CONSTRAINT fk_rails_5cd975e78e FOREIGN KEY (reservation_id) REFERENCES public.reservations(id);


--
-- Name: notes fk_rails_7f2323ad43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_7f2323ad43 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: finalists fk_rails_c29553688f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finalists
    ADD CONSTRAINT fk_rails_c29553688f FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: ranks fk_rails_c35ad96879; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ranks
    ADD CONSTRAINT fk_rails_c35ad96879 FOREIGN KEY (reservation_id) REFERENCES public.reservations(id);


--
-- Name: orders fk_rails_dfb33b2de0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_dfb33b2de0 FOREIGN KEY (membership_id) REFERENCES public.memberships(id);


--
-- Name: claims fk_rails_fc0a74d7fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT fk_rails_fc0a74d7fa FOREIGN KEY (reservation_id) REFERENCES public.reservations(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20181006225322'),
('20181015045730'),
('20181015051317'),
('20181015061958'),
('20181015083953'),
('20181016052349'),
('20181018181600'),
('20181018184020'),
('20181020040210'),
('20181024181647'),
('20181025182614'),
('20181026015736'),
('20181027035935'),
('20181027041136'),
('20181027051547'),
('20181027053114'),
('20181027222153'),
('20181031181612'),
('20181102050449'),
('20181102052907'),
('20181114051837'),
('20181114054300'),
('20181115171944'),
('20181115172836'),
('20181126181026'),
('20181129183755'),
('20190107083301'),
('20190113184237'),
('20190201214219'),
('20190201224824'),
('20190202023301'),
('20190211183423'),
('20190211184322'),
('20190211185059'),
('20190219053046'),
('20190219180820'),
('20190314180805'),
('20190406052259'),
('20190422191019'),
('20190422191637'),
('20190603022833'),
('20190603043114'),
('20190620050122'),
('20190627055058'),
('20190627092208'),
('20190707220026'),
('20190716055122'),
('20190716055132'),
('20190825022040'),
('20191009182159'),
('20191020043744'),
('20191020174055'),
('20191024180734'),
('20191031051223'),
('20191128184513'),
('20191201185444'),
('20191208185952'),
('20191209052126'),
('20191221233951'),
('20191229203558'),
('20191231004921'),
('20200304210408'),
('20200324223914'),
('20200324223922'),
('20200525204858'),
('20200629100946'),
('20200717051724'),
('20200717081753'),
('20200719215504'),
('20200720235919'),
('20200724003813'),
('20210819040007');


