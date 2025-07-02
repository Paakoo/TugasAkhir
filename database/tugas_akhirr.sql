--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-06-08 22:45:33

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16449)
-- Name: absensi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.absensi (
    id_absensi integer NOT NULL,
    id_karyawan integer NOT NULL,
    nama_karyawan character varying(100) NOT NULL,
    work_type character varying(100) DEFAULT NULL::character varying,
    office character varying(100) DEFAULT NULL::character varying,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    absensi_masuk timestamp without time zone,
    absensi_pulang timestamp without time zone
);


ALTER TABLE public.absensi OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16448)
-- Name: absensi_id_absensi_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.absensi_id_absensi_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.absensi_id_absensi_seq OWNER TO postgres;

--
-- TOC entry 4879 (class 0 OID 0)
-- Dependencies: 221
-- Name: absensi_id_absensi_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.absensi_id_absensi_seq OWNED BY public.absensi.id_absensi;


--
-- TOC entry 218 (class 1259 OID 16427)
-- Name: karyawan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.karyawan (
    id_karyawan integer NOT NULL,
    nama_karyawan character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password character varying(100) NOT NULL,
    role character varying(5) DEFAULT 'user'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT karyawan_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'user'::character varying])::text[])))
);


ALTER TABLE public.karyawan OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16426)
-- Name: karyawan_id_karyawan_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.karyawan_id_karyawan_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.karyawan_id_karyawan_seq OWNER TO postgres;

--
-- TOC entry 4880 (class 0 OID 0)
-- Dependencies: 217
-- Name: karyawan_id_karyawan_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.karyawan_id_karyawan_seq OWNED BY public.karyawan.id_karyawan;


--
-- TOC entry 220 (class 1259 OID 16441)
-- Name: lokasi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lokasi (
    id_lokasi integer NOT NULL,
    nama_lokasi character varying(100) NOT NULL,
    latitude numeric(10,8) NOT NULL,
    longitude numeric(11,8) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.lokasi OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16440)
-- Name: lokasi_id_lokasi_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lokasi_id_lokasi_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lokasi_id_lokasi_seq OWNER TO postgres;

--
-- TOC entry 4881 (class 0 OID 0)
-- Dependencies: 219
-- Name: lokasi_id_lokasi_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lokasi_id_lokasi_seq OWNED BY public.lokasi.id_lokasi;


--
-- TOC entry 4710 (class 2604 OID 16452)
-- Name: absensi id_absensi; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.absensi ALTER COLUMN id_absensi SET DEFAULT nextval('public.absensi_id_absensi_seq'::regclass);


--
-- TOC entry 4705 (class 2604 OID 16430)
-- Name: karyawan id_karyawan; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.karyawan ALTER COLUMN id_karyawan SET DEFAULT nextval('public.karyawan_id_karyawan_seq'::regclass);


--
-- TOC entry 4708 (class 2604 OID 16444)
-- Name: lokasi id_lokasi; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lokasi ALTER COLUMN id_lokasi SET DEFAULT nextval('public.lokasi_id_lokasi_seq'::regclass);


--
-- TOC entry 4873 (class 0 OID 16449)
-- Dependencies: 222
-- Data for Name: absensi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.absensi (id_absensi, id_karyawan, nama_karyawan, work_type, office, latitude, longitude, absensi_masuk, absensi_pulang) FROM stdin;
1	7	Bagus Setiyo	WFA	Work From Anywhere	-7.28936	112.799	2025-01-13 12:55:33	\N
2	7	Bagus Setiyo	WFA	Work From Anywhere	-7.28936	112.799	2025-01-19 08:38:17	\N
3	7	Bagus Setiyo	WFA	Work From Anywhere	-7.2893228	112.7987656	2025-02-23 14:27:02.093144	\N
4	6	Alan	WFO	PENS	-7.2895	112.798	2025-03-14 08:05:22	\N
5	7	Bagus Setiyo	WFO	PENS	-7.2895	112.798	2025-03-15 08:01:45	\N
6	9	Troy	WFA	Work From Anywhere	-7.29	112.7975	2025-03-16 08:10:33	\N
7	8	Latif	WFA	Work From Anywhere	-7.2901	112.7974	2025-03-17 08:13:21	\N
8	5	Imam	WFO	Office Pertama	-6.2001	106.8163	2025-03-18 07:58:49	\N
9	7	Bagus Setiyo	WFO	Office Pertama	-6.2002	106.8161	2025-03-19 08:00:17	\N
10	9	Troy	WFA	Work From Anywhere	-7.3001	112.8022	2025-03-20 08:20:00	\N
11	5	Imam	WFA	Work From Anywhere	-7.3002	112.8023	2025-03-21 08:22:11	\N
12	6	Alan	WFO	Office Kedua	-6.9147	107.6098	2025-03-22 07:45:33	\N
13	8	Latif	WFO	Office Kedua	-6.9148	107.6099	2025-03-23 07:50:15	\N
14	6	Alan	WFO	PENS	-7.2895	112.798	2025-02-14 08:05:22	\N
15	7	Bagus Setiyo	WFO	PENS	-7.2895	112.798	2025-02-14 08:01:45	\N
16	9	Troy	WFA	Work From Anywhere	-7.29	112.7975	2025-02-14 08:10:33	\N
17	8	Latif	WFA	Work From Anywhere	-7.2901	112.7974	2025-02-14 07:13:21	\N
18	5	Imam	WFO	Office Pertama	-6.2001	106.8163	2025-02-14 07:58:49	\N
20	7	Bagus Setiyo	WFA	Work From Anywhere	-7.2893801	112.7987973	2025-04-28 19:40:42.578588	\N
26	7	Bagus Setiyo	WFA	Work From Anywhere	-7.2893799	112.7987631	2025-05-19 23:13:20.949156	\N
32	7	Bagus Setiyo	WFO	Office Pertama	-7.7700667	111.4821461	2025-06-02 00:32:32.648237	\N
\.


--
-- TOC entry 4869 (class 0 OID 16427)
-- Dependencies: 218
-- Data for Name: karyawan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.karyawan (id_karyawan, nama_karyawan, email, password, role, created_at) FROM stdin;
2	coba	cintaastutish@gmail.com	123	user	2025-02-11 13:37:24.044103
3	test	elmazulaikay@gmail.com	123	user	2025-02-11 13:37:24.044103
5	Imam	imam@gmail.com	123	user	2025-02-11 13:37:24.044103
6	Alan	alan@gmail.com	123	user	2025-02-11 13:37:24.044103
8	Latif	latif@gmail.com	123	user	2025-02-11 13:37:24.044103
9	Troy	troy@gmail.com	123	user	2025-02-11 13:37:24.044103
7	Bagus Setiyo	bagus@gmail.com	123	user	2025-02-11 13:37:24.044103
10	admin	admin@gmail.com	admin	admin	2025-02-26 01:04:54.926605
\.


--
-- TOC entry 4871 (class 0 OID 16441)
-- Dependencies: 220
-- Data for Name: lokasi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lokasi (id_lokasi, nama_lokasi, latitude, longitude, created_at) FROM stdin;
1	Kantor A	-7.77016671	111.48200720	2025-02-11 13:37:24.044103
2	Kantor B	-7.77046782	111.47960511	2025-02-11 13:37:24.044103
\.


--
-- TOC entry 4882 (class 0 OID 0)
-- Dependencies: 221
-- Name: absensi_id_absensi_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.absensi_id_absensi_seq', 32, true);


--
-- TOC entry 4883 (class 0 OID 0)
-- Dependencies: 217
-- Name: karyawan_id_karyawan_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.karyawan_id_karyawan_seq', 20, true);


--
-- TOC entry 4884 (class 0 OID 0)
-- Dependencies: 219
-- Name: lokasi_id_lokasi_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lokasi_id_lokasi_seq', 2, true);


--
-- TOC entry 4721 (class 2606 OID 16456)
-- Name: absensi absensi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.absensi
    ADD CONSTRAINT absensi_pkey PRIMARY KEY (id_absensi);


--
-- TOC entry 4715 (class 2606 OID 16439)
-- Name: karyawan karyawan_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.karyawan
    ADD CONSTRAINT karyawan_email_key UNIQUE (email);


--
-- TOC entry 4717 (class 2606 OID 16437)
-- Name: karyawan karyawan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.karyawan
    ADD CONSTRAINT karyawan_pkey PRIMARY KEY (id_karyawan);


--
-- TOC entry 4719 (class 2606 OID 16447)
-- Name: lokasi lokasi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lokasi
    ADD CONSTRAINT lokasi_pkey PRIMARY KEY (id_lokasi);


--
-- TOC entry 4722 (class 2606 OID 16457)
-- Name: absensi absensi_id_karyawan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.absensi
    ADD CONSTRAINT absensi_id_karyawan_fkey FOREIGN KEY (id_karyawan) REFERENCES public.karyawan(id_karyawan);


-- Completed on 2025-06-08 22:45:33

--
-- PostgreSQL database dump complete
--

