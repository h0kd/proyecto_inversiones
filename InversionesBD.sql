--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2024-12-03 10:06:44

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

--
-- TOC entry 239 (class 1255 OID 16540)
-- Name: actualizar_plazo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_plazo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.Plazo := DATE_PART('day', NEW.FechaVencimiento - NEW.FechaEmision);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.actualizar_plazo() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 232 (class 1259 OID 16478)
-- Name: accion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accion (
    id_accion integer NOT NULL,
    ticker character varying(15) NOT NULL,
    nombre character varying(100) NOT NULL,
    mercado character varying(50),
    sector character varying(50)
);


ALTER TABLE public.accion OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16477)
-- Name: accion_id_accion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accion_id_accion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.accion_id_accion_seq OWNER TO postgres;

--
-- TOC entry 4972 (class 0 OID 0)
-- Dependencies: 231
-- Name: accion_id_accion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.accion_id_accion_seq OWNED BY public.accion.id_accion;


--
-- TOC entry 226 (class 1259 OID 16440)
-- Name: boletagarantia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.boletagarantia (
    numero integer NOT NULL,
    id_banco integer NOT NULL,
    id_beneficiario integer NOT NULL,
    glosa text,
    vencimiento date NOT NULL,
    moneda character varying(10) NOT NULL,
    monto numeric(15,2) NOT NULL,
    fechaemision date NOT NULL,
    estado character varying(20) DEFAULT 'Activa'::character varying NOT NULL,
    documento character varying(255)
);


ALTER TABLE public.boletagarantia OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16439)
-- Name: boletagarantia_numero_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.boletagarantia_numero_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.boletagarantia_numero_seq OWNER TO postgres;

--
-- TOC entry 4973 (class 0 OID 0)
-- Dependencies: 225
-- Name: boletagarantia_numero_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.boletagarantia_numero_seq OWNED BY public.boletagarantia.numero;


--
-- TOC entry 236 (class 1259 OID 16499)
-- Name: depositoaplazo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.depositoaplazo (
    id_deposito bigint NOT NULL,
    id_entidadcomercial integer NOT NULL,
    id_banco integer NOT NULL,
    fechaemision date NOT NULL,
    fechavencimiento date NOT NULL,
    moneda character varying(10) NOT NULL,
    montoinicial numeric(15,2) NOT NULL,
    montofinal numeric(15,2),
    comprobante character varying(255),
    tipodeposito character varying(20),
    interesganado numeric(15,2) DEFAULT 0.00,
    plazo integer,
    tasainteres numeric(6,4),
    reajusteganado numeric(15,2),
    capitalrenovacion numeric(15,2),
    fechaemisionrenovacion date,
    tasainteresrenovacion numeric(5,2),
    plazorenovacion integer,
    tasaperiodo numeric(5,2),
    fechavencimientorenovacion date,
    totalpagarrenovacion numeric(15,2)
);


ALTER TABLE public.depositoaplazo OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16498)
-- Name: depositoaplazo_id_deposito_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.depositoaplazo_id_deposito_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.depositoaplazo_id_deposito_seq OWNER TO postgres;

--
-- TOC entry 4974 (class 0 OID 0)
-- Dependencies: 235
-- Name: depositoaplazo_id_deposito_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.depositoaplazo_id_deposito_seq OWNED BY public.depositoaplazo.id_deposito;


--
-- TOC entry 234 (class 1259 OID 16487)
-- Name: dividendos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dividendos (
    id_dividendo integer NOT NULL,
    id_accion integer NOT NULL,
    monto numeric(15,2) NOT NULL,
    fecha date NOT NULL
);


ALTER TABLE public.dividendos OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16486)
-- Name: dividendos_id_dividendo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dividendos_id_dividendo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dividendos_id_dividendo_seq OWNER TO postgres;

--
-- TOC entry 4975 (class 0 OID 0)
-- Dependencies: 233
-- Name: dividendos_id_dividendo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dividendos_id_dividendo_seq OWNED BY public.dividendos.id_dividendo;


--
-- TOC entry 218 (class 1259 OID 16386)
-- Name: entidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entidad (
    id_entidad integer NOT NULL,
    rut character varying(20) NOT NULL,
    nombre character varying(100) NOT NULL,
    tipoentidad character varying(50) NOT NULL,
    contacto character varying(100),
    email character varying(100),
    fonofijo character varying(15),
    fonomovil character varying(15)
);


ALTER TABLE public.entidad OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16385)
-- Name: entidad_id_entidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entidad_id_entidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.entidad_id_entidad_seq OWNER TO postgres;

--
-- TOC entry 4976 (class 0 OID 0)
-- Dependencies: 217
-- Name: entidad_id_entidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entidad_id_entidad_seq OWNED BY public.entidad.id_entidad;


--
-- TOC entry 220 (class 1259 OID 16395)
-- Name: entidadcomercial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entidadcomercial (
    id_entidad integer NOT NULL,
    rut character varying(20) NOT NULL,
    nombre character varying(100) NOT NULL,
    tipoentidad character varying(50) NOT NULL
);


ALTER TABLE public.entidadcomercial OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16394)
-- Name: entidadcomercial_id_entidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entidadcomercial_id_entidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.entidadcomercial_id_entidad_seq OWNER TO postgres;

--
-- TOC entry 4977 (class 0 OID 0)
-- Dependencies: 219
-- Name: entidadcomercial_id_entidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entidadcomercial_id_entidad_seq OWNED BY public.entidadcomercial.id_entidad;


--
-- TOC entry 224 (class 1259 OID 16423)
-- Name: facturas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facturas (
    numerofactura integer NOT NULL,
    id_corredora integer NOT NULL,
    fecha date NOT NULL,
    tipo character varying(50) NOT NULL,
    cantidad integer NOT NULL,
    valor numeric(15,2) NOT NULL,
    subtotal numeric(15,2) NOT NULL,
    comision numeric(15,2),
    gasto numeric(15,2),
    adjuntofactura character varying(255),
    id_tipoinversion integer NOT NULL,
    rut character varying(20),
    preciounitario numeric(15,2),
    nombreactivo character varying(100) NOT NULL
);


ALTER TABLE public.facturas OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16422)
-- Name: facturas_numerofactura_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.facturas_numerofactura_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.facturas_numerofactura_seq OWNER TO postgres;

--
-- TOC entry 4978 (class 0 OID 0)
-- Dependencies: 223
-- Name: facturas_numerofactura_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.facturas_numerofactura_seq OWNED BY public.facturas.numerofactura;


--
-- TOC entry 228 (class 1259 OID 16459)
-- Name: fondosmutuos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fondosmutuos (
    id_fondo integer NOT NULL,
    nombre character varying(100) NOT NULL,
    montoinvertido numeric(15,2) NOT NULL,
    rentabilidad numeric(5,2),
    montofinal numeric(15,2),
    id_entidad integer NOT NULL,
    comprobante character varying(255),
    tiporiesgo character varying(20),
    fechainicio date,
    fechatermino date,
    id_banco integer
);


ALTER TABLE public.fondosmutuos OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16458)
-- Name: fondosmutuos_id_fondo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fondosmutuos_id_fondo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fondosmutuos_id_fondo_seq OWNER TO postgres;

--
-- TOC entry 4979 (class 0 OID 0)
-- Dependencies: 227
-- Name: fondosmutuos_id_fondo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fondosmutuos_id_fondo_seq OWNED BY public.fondosmutuos.id_fondo;


--
-- TOC entry 230 (class 1259 OID 16471)
-- Name: polizas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.polizas (
    numero integer NOT NULL,
    tipoasegurado character varying(50) NOT NULL,
    fechainicio date NOT NULL,
    fechatermino date NOT NULL,
    monto numeric(15,2) NOT NULL,
    adjuntopoliza character varying(255)
);


ALTER TABLE public.polizas OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16470)
-- Name: polizas_numero_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.polizas_numero_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.polizas_numero_seq OWNER TO postgres;

--
-- TOC entry 4980 (class 0 OID 0)
-- Dependencies: 229
-- Name: polizas_numero_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.polizas_numero_seq OWNED BY public.polizas.numero;


--
-- TOC entry 222 (class 1259 OID 16416)
-- Name: tipoinversion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipoinversion (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL
);


ALTER TABLE public.tipoinversion OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16415)
-- Name: tipoinversion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tipoinversion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tipoinversion_id_seq OWNER TO postgres;

--
-- TOC entry 4981 (class 0 OID 0)
-- Dependencies: 221
-- Name: tipoinversion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tipoinversion_id_seq OWNED BY public.tipoinversion.id;


--
-- TOC entry 238 (class 1259 OID 16520)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombreusuario character varying(50) NOT NULL,
    "contraseña" character varying(255) NOT NULL
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16519)
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO postgres;

--
-- TOC entry 4982 (class 0 OID 0)
-- Dependencies: 237
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- TOC entry 4754 (class 2604 OID 16481)
-- Name: accion id_accion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accion ALTER COLUMN id_accion SET DEFAULT nextval('public.accion_id_accion_seq'::regclass);


--
-- TOC entry 4750 (class 2604 OID 16443)
-- Name: boletagarantia numero; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.boletagarantia ALTER COLUMN numero SET DEFAULT nextval('public.boletagarantia_numero_seq'::regclass);


--
-- TOC entry 4756 (class 2604 OID 16547)
-- Name: depositoaplazo id_deposito; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depositoaplazo ALTER COLUMN id_deposito SET DEFAULT nextval('public.depositoaplazo_id_deposito_seq'::regclass);


--
-- TOC entry 4755 (class 2604 OID 16490)
-- Name: dividendos id_dividendo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dividendos ALTER COLUMN id_dividendo SET DEFAULT nextval('public.dividendos_id_dividendo_seq'::regclass);


--
-- TOC entry 4746 (class 2604 OID 16389)
-- Name: entidad id_entidad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entidad ALTER COLUMN id_entidad SET DEFAULT nextval('public.entidad_id_entidad_seq'::regclass);


--
-- TOC entry 4747 (class 2604 OID 16398)
-- Name: entidadcomercial id_entidad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entidadcomercial ALTER COLUMN id_entidad SET DEFAULT nextval('public.entidadcomercial_id_entidad_seq'::regclass);


--
-- TOC entry 4749 (class 2604 OID 16426)
-- Name: facturas numerofactura; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facturas ALTER COLUMN numerofactura SET DEFAULT nextval('public.facturas_numerofactura_seq'::regclass);


--
-- TOC entry 4752 (class 2604 OID 16462)
-- Name: fondosmutuos id_fondo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fondosmutuos ALTER COLUMN id_fondo SET DEFAULT nextval('public.fondosmutuos_id_fondo_seq'::regclass);


--
-- TOC entry 4753 (class 2604 OID 16474)
-- Name: polizas numero; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polizas ALTER COLUMN numero SET DEFAULT nextval('public.polizas_numero_seq'::regclass);


--
-- TOC entry 4748 (class 2604 OID 16419)
-- Name: tipoinversion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipoinversion ALTER COLUMN id SET DEFAULT nextval('public.tipoinversion_id_seq'::regclass);


--
-- TOC entry 4758 (class 2604 OID 16523)
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- TOC entry 4960 (class 0 OID 16478)
-- Dependencies: 232
-- Data for Name: accion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accion (id_accion, ticker, nombre, mercado, sector) FROM stdin;
\.


--
-- TOC entry 4954 (class 0 OID 16440)
-- Dependencies: 226
-- Data for Name: boletagarantia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.boletagarantia (numero, id_banco, id_beneficiario, glosa, vencimiento, moneda, monto, fechaemision, estado, documento) FROM stdin;
2	20	13	Garantía por contrato de arriendo de oficina en Santiago.	2025-08-30	CLP	8500000.00	2023-08-23	Vigente	\N
1	18	11	Garantía por contrato de servicios financieros	2025-12-31	CLP	3500000.00	2023-06-15	Vigente	static/uploads/boleta_garantiaTest1.pdf
\.


--
-- TOC entry 4964 (class 0 OID 16499)
-- Dependencies: 236
-- Data for Name: depositoaplazo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.depositoaplazo (id_deposito, id_entidadcomercial, id_banco, fechaemision, fechavencimiento, moneda, montoinicial, montofinal, comprobante, tipodeposito, interesganado, plazo, tasainteres, reajusteganado, capitalrenovacion, fechaemisionrenovacion, tasainteresrenovacion, plazorenovacion, tasaperiodo, fechavencimientorenovacion, totalpagarrenovacion) FROM stdin;
26430963782	15	20	2024-10-21	2024-11-25	CLP	370206.00	\N	static/uploads/deposito_a_plazoTest.pdf	Renovable	734.00	\N	0.1700	\N	370206.00	2024-10-21	0.17	35	0.20	2024-12-30	371676.00
45673892165	16	21	2024-12-01	2025-01-15	CLP	450000.00	\N	static/uploads/deposito_a_plazoTest3.pdf	Renovable	675.00	\N	0.1500	\N	450000.00	2024-12-01	0.15	45	0.18	2025-02-28	451350.00
987654321	17	19	2024-12-15	2025-06-15	CLP	1500000.00	\N	static/uploads/deposito_a_plazoTest5.pdf	Renovable	5000.00	\N	0.2500	\N	1500000.00	2024-12-15	0.30	182	0.35	2025-12-15	1530000.00
\.


--
-- TOC entry 4962 (class 0 OID 16487)
-- Dependencies: 234
-- Data for Name: dividendos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dividendos (id_dividendo, id_accion, monto, fecha) FROM stdin;
\.


--
-- TOC entry 4946 (class 0 OID 16386)
-- Dependencies: 218
-- Data for Name: entidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entidad (id_entidad, rut, nombre, tipoentidad, contacto, email, fonofijo, fonomovil) FROM stdin;
1	966654503	ITAU CORREDORES DE BOLSA LTDA	Corredora	\N	\N	\N	\N
5	TEMP-20241128104501	BANCO DE PRUEBAS	Banco	\N	\N	\N	\N
6	TEMP-20241128105936	BANCO DE EJEMPLO	Banco	\N	\N	\N	\N
7	76123456	CORREDORA ABC	Corredora	\N	\N	\N	\N
8	76543210	CORREDORA XYZ	Corredora	\N	\N	\N	\N
10	TEMP-20241129112604	BANCO EJEMPLO	Banco	\N	\N	\N	\N
15	TEMP-20241129124600	BANCO CHILE	Banco	\N	\N	\N	\N
18	TEMP-20241129151151	BANCO ESTADO	Banco	\N	\N	\N	\N
19	TEMP-20241129151420	BANCO DE CHILE	Banco	\N	\N	\N	\N
20	TEMP-20241202082515	BANCO SANTANDER	Banco	\N	\N	\N	\N
21	TEMP-20241202155218	BANCO ITAÚ	Banco	\N	\N	\N	\N
\.


--
-- TOC entry 4948 (class 0 OID 16395)
-- Dependencies: 220
-- Data for Name: entidadcomercial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entidadcomercial (id_entidad, rut, nombre, tipoentidad) FROM stdin;
3	TEMP-20241128104501	EMPRESA ABC	Empresa
4	TEMP-20241128105936	INVERSIONES XYZ	Empresa
6	TEMP-20241129112604	EMPRESA FINANCIERA ABC	Empresa
8	TEMP-20241129124600	INVERSIONES SOLAR	Empresa
11	TEMP-20241129151151	GLOBAL ASSETS S.A.	Empresa
12	TEMP-20241129151420	CAPITAL PLUS S.A.	Empresa
13	TEMP-20241202082515	INVERSIONES PATAGONIA S.A.	Cliente
15	156246468	STUARDO BUSTOS FELIPE DANIEL	cliente
16	123456789	JUAN PÉREZ	cliente
17	98765432K	MARÍA GONZÁLEZ LÓPEZ	cliente
\.


--
-- TOC entry 4952 (class 0 OID 16423)
-- Dependencies: 224
-- Data for Name: facturas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.facturas (numerofactura, id_corredora, fecha, tipo, cantidad, valor, subtotal, comision, gasto, adjuntofactura, id_tipoinversion, rut, preciounitario, nombreactivo) FROM stdin;
1961295	1	2019-12-17	Compra	8048	1205937.00	1195128.00	4183.00	4900.00	static\\uploads\\factura_test.pdf	1	966654503	148.50	CRUZADOS
4728165	1	2020-01-01	Compra	9523	1490149.00	1480826.50	4323.00	5000.00	static/uploads/factura_ficticia.pdf	1	966654503	155.50	FALABELLA
12345	7	2024-11-28	Compra	100	150150.00	150000.00	100.00	50.00	static/uploads/factura_12345.pdf	1	76123456	1500.00	CRUZADOS
54321	8	2024-11-27	Venta	200	500275.00	500000.00	200.00	75.00	static/uploads/factura_54321.pdf	2	76543210	2500.00	FALABELLA
98765	8	2024-11-29	Venta	150	255225.00	255000.00	150.00	75.00	static/uploads/factura_98765.pdf	2	76543210	1700.00	CRUZADOS
\.


--
-- TOC entry 4956 (class 0 OID 16459)
-- Dependencies: 228
-- Data for Name: fondosmutuos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fondosmutuos (id_fondo, nombre, montoinvertido, rentabilidad, montofinal, id_entidad, comprobante, tiporiesgo, fechainicio, fechatermino, id_banco) FROM stdin;
9	FONDO AHORRO CLP	5000000.00	\N	7500000.00	8	static/uploads/fondo_mutuo_test2.pdf	Medio	2020-01-15	2023-01-15	15
7	FONDO ESTABLE ABC	1500000.00	\N	1800000.00	3	static/uploads/fondo_mutuo_test.pdf	Medio	2024-01-01	2025-01-01	6
10	FONDO RENTA FIJA CLP	3500000.00	\N	\N	11	static/uploads/fondo_mutuo_test3.pdf	Bajo	2023-07-15	\N	18
11	FONDO MIXTO INTERNACIONAL USD	8500000.00	\N	\N	12	static/uploads/fondo_mutuo_test4.pdf	Medio	2022-03-01	\N	19
\.


--
-- TOC entry 4958 (class 0 OID 16471)
-- Dependencies: 230
-- Data for Name: polizas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.polizas (numero, tipoasegurado, fechainicio, fechatermino, monto, adjuntopoliza) FROM stdin;
\.


--
-- TOC entry 4950 (class 0 OID 16416)
-- Dependencies: 222
-- Data for Name: tipoinversion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tipoinversion (id, nombre) FROM stdin;
1	Compra
2	Venta
\.


--
-- TOC entry 4966 (class 0 OID 16520)
-- Dependencies: 238
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id, nombreusuario, "contraseña") FROM stdin;
1	admin	scrypt:32768:8:1$a9xceycXX5B9oyRw$28aca242c210f02798db2d66e85fe147f8b7ac9e3b63e53f6862dd409bc1783cd03e69a1c7e8594eca1907beee2d3372745c34b05f1430f3d20d36057b53fbc3
\.


--
-- TOC entry 4983 (class 0 OID 0)
-- Dependencies: 231
-- Name: accion_id_accion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.accion_id_accion_seq', 1, false);


--
-- TOC entry 4984 (class 0 OID 0)
-- Dependencies: 225
-- Name: boletagarantia_numero_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.boletagarantia_numero_seq', 2, true);


--
-- TOC entry 4985 (class 0 OID 0)
-- Dependencies: 235
-- Name: depositoaplazo_id_deposito_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.depositoaplazo_id_deposito_seq', 4, true);


--
-- TOC entry 4986 (class 0 OID 0)
-- Dependencies: 233
-- Name: dividendos_id_dividendo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dividendos_id_dividendo_seq', 1, false);


--
-- TOC entry 4987 (class 0 OID 0)
-- Dependencies: 217
-- Name: entidad_id_entidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entidad_id_entidad_seq', 21, true);


--
-- TOC entry 4988 (class 0 OID 0)
-- Dependencies: 219
-- Name: entidadcomercial_id_entidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.entidadcomercial_id_entidad_seq', 17, true);


--
-- TOC entry 4989 (class 0 OID 0)
-- Dependencies: 223
-- Name: facturas_numerofactura_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.facturas_numerofactura_seq', 1, false);


--
-- TOC entry 4990 (class 0 OID 0)
-- Dependencies: 227
-- Name: fondosmutuos_id_fondo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fondosmutuos_id_fondo_seq', 11, true);


--
-- TOC entry 4991 (class 0 OID 0)
-- Dependencies: 229
-- Name: polizas_numero_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.polizas_numero_seq', 1, false);


--
-- TOC entry 4992 (class 0 OID 0)
-- Dependencies: 221
-- Name: tipoinversion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipoinversion_id_seq', 2, true);


--
-- TOC entry 4993 (class 0 OID 0)
-- Dependencies: 237
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 1, true);


--
-- TOC entry 4778 (class 2606 OID 16483)
-- Name: accion accion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accion
    ADD CONSTRAINT accion_pkey PRIMARY KEY (id_accion);


--
-- TOC entry 4780 (class 2606 OID 16485)
-- Name: accion accion_ticker_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accion
    ADD CONSTRAINT accion_ticker_key UNIQUE (ticker);


--
-- TOC entry 4772 (class 2606 OID 16447)
-- Name: boletagarantia boletagarantia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.boletagarantia
    ADD CONSTRAINT boletagarantia_pkey PRIMARY KEY (numero);


--
-- TOC entry 4784 (class 2606 OID 16549)
-- Name: depositoaplazo depositoaplazo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depositoaplazo
    ADD CONSTRAINT depositoaplazo_pkey PRIMARY KEY (id_deposito);


--
-- TOC entry 4782 (class 2606 OID 16492)
-- Name: dividendos dividendos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dividendos
    ADD CONSTRAINT dividendos_pkey PRIMARY KEY (id_dividendo);


--
-- TOC entry 4760 (class 2606 OID 16391)
-- Name: entidad entidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entidad
    ADD CONSTRAINT entidad_pkey PRIMARY KEY (id_entidad);


--
-- TOC entry 4762 (class 2606 OID 16393)
-- Name: entidad entidad_rut_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entidad
    ADD CONSTRAINT entidad_rut_key UNIQUE (rut);


--
-- TOC entry 4764 (class 2606 OID 16400)
-- Name: entidadcomercial entidadcomercial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entidadcomercial
    ADD CONSTRAINT entidadcomercial_pkey PRIMARY KEY (id_entidad);


--
-- TOC entry 4766 (class 2606 OID 16402)
-- Name: entidadcomercial entidadcomercial_rut_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entidadcomercial
    ADD CONSTRAINT entidadcomercial_rut_key UNIQUE (rut);


--
-- TOC entry 4770 (class 2606 OID 16428)
-- Name: facturas facturas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facturas
    ADD CONSTRAINT facturas_pkey PRIMARY KEY (numerofactura);


--
-- TOC entry 4774 (class 2606 OID 16464)
-- Name: fondosmutuos fondosmutuos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fondosmutuos
    ADD CONSTRAINT fondosmutuos_pkey PRIMARY KEY (id_fondo);


--
-- TOC entry 4776 (class 2606 OID 16476)
-- Name: polizas polizas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polizas
    ADD CONSTRAINT polizas_pkey PRIMARY KEY (numero);


--
-- TOC entry 4768 (class 2606 OID 16421)
-- Name: tipoinversion tipoinversion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipoinversion
    ADD CONSTRAINT tipoinversion_pkey PRIMARY KEY (id);


--
-- TOC entry 4786 (class 2606 OID 16527)
-- Name: usuarios usuarios_nombreusuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_nombreusuario_key UNIQUE (nombreusuario);


--
-- TOC entry 4788 (class 2606 OID 16525)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 4799 (class 2620 OID 16541)
-- Name: depositoaplazo trigger_actualizar_plazo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_actualizar_plazo BEFORE INSERT OR UPDATE ON public.depositoaplazo FOR EACH ROW EXECUTE FUNCTION public.actualizar_plazo();

ALTER TABLE public.depositoaplazo DISABLE TRIGGER trigger_actualizar_plazo;


--
-- TOC entry 4791 (class 2606 OID 16448)
-- Name: boletagarantia boletagarantia_id_banco_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.boletagarantia
    ADD CONSTRAINT boletagarantia_id_banco_fkey FOREIGN KEY (id_banco) REFERENCES public.entidad(id_entidad);


--
-- TOC entry 4792 (class 2606 OID 16453)
-- Name: boletagarantia boletagarantia_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.boletagarantia
    ADD CONSTRAINT boletagarantia_id_cliente_fkey FOREIGN KEY (id_beneficiario) REFERENCES public.entidadcomercial(id_entidad);


--
-- TOC entry 4796 (class 2606 OID 16510)
-- Name: depositoaplazo depositoaplazo_id_banco_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depositoaplazo
    ADD CONSTRAINT depositoaplazo_id_banco_fkey FOREIGN KEY (id_banco) REFERENCES public.entidad(id_entidad);


--
-- TOC entry 4797 (class 2606 OID 16505)
-- Name: depositoaplazo depositoaplazo_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depositoaplazo
    ADD CONSTRAINT depositoaplazo_id_empresa_fkey FOREIGN KEY (id_entidadcomercial) REFERENCES public.entidadcomercial(id_entidad);


--
-- TOC entry 4795 (class 2606 OID 16493)
-- Name: dividendos dividendos_id_accion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dividendos
    ADD CONSTRAINT dividendos_id_accion_fkey FOREIGN KEY (id_accion) REFERENCES public.accion(id_accion);


--
-- TOC entry 4789 (class 2606 OID 16429)
-- Name: facturas facturas_id_corredora_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facturas
    ADD CONSTRAINT facturas_id_corredora_fkey FOREIGN KEY (id_corredora) REFERENCES public.entidad(id_entidad);


--
-- TOC entry 4790 (class 2606 OID 16434)
-- Name: facturas facturas_id_tipoinversion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facturas
    ADD CONSTRAINT facturas_id_tipoinversion_fkey FOREIGN KEY (id_tipoinversion) REFERENCES public.tipoinversion(id);


--
-- TOC entry 4798 (class 2606 OID 16542)
-- Name: depositoaplazo fk_deposito_id_entidadcomercial; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depositoaplazo
    ADD CONSTRAINT fk_deposito_id_entidadcomercial FOREIGN KEY (id_entidadcomercial) REFERENCES public.entidadcomercial(id_entidad);


--
-- TOC entry 4793 (class 2606 OID 16528)
-- Name: fondosmutuos fondosmutuos_id_banco_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fondosmutuos
    ADD CONSTRAINT fondosmutuos_id_banco_fkey FOREIGN KEY (id_banco) REFERENCES public.entidad(id_entidad);


--
-- TOC entry 4794 (class 2606 OID 16533)
-- Name: fondosmutuos fondosmutuos_id_entidadcomercial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fondosmutuos
    ADD CONSTRAINT fondosmutuos_id_entidadcomercial_fkey FOREIGN KEY (id_entidad) REFERENCES public.entidadcomercial(id_entidad);


-- Completed on 2024-12-03 10:06:44

--
-- PostgreSQL database dump complete
--

