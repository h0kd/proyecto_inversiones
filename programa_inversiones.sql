PGDMP  1                    |           programa_inversiones    17.2    17.2 a    i           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            j           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            k           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            l           1262    16384    programa_inversiones    DATABASE     �   CREATE DATABASE programa_inversiones WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Chile.1252';
 $   DROP DATABASE programa_inversiones;
                     postgres    false            �            1255    16540    actualizar_plazo()    FUNCTION     �   CREATE FUNCTION public.actualizar_plazo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.Plazo := DATE_PART('day', NEW.FechaVencimiento - NEW.FechaEmision);
    RETURN NEW;
END;
$$;
 )   DROP FUNCTION public.actualizar_plazo();
       public               postgres    false            �            1259    16478    accion    TABLE     �   CREATE TABLE public.accion (
    id_accion integer NOT NULL,
    ticker character varying(15) NOT NULL,
    nombre character varying(100) NOT NULL,
    mercado character varying(50),
    sector character varying(50)
);
    DROP TABLE public.accion;
       public         heap r       postgres    false            �            1259    16477    accion_id_accion_seq    SEQUENCE     �   CREATE SEQUENCE public.accion_id_accion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.accion_id_accion_seq;
       public               postgres    false    232            m           0    0    accion_id_accion_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.accion_id_accion_seq OWNED BY public.accion.id_accion;
          public               postgres    false    231            �            1259    16440    boletagarantia    TABLE     �  CREATE TABLE public.boletagarantia (
    numero integer NOT NULL,
    id_banco integer NOT NULL,
    id_beneficiario integer NOT NULL,
    glosa text,
    vencimiento date NOT NULL,
    moneda character varying(10) NOT NULL,
    monto numeric(15,2) NOT NULL,
    fechaemision date NOT NULL,
    estado character varying(20) DEFAULT 'Activa'::character varying NOT NULL,
    documento character varying(255),
    tomada_por_empresa character varying(255),
    tomada_por_rut character varying(20)
);
 "   DROP TABLE public.boletagarantia;
       public         heap r       postgres    false            �            1259    16439    boletagarantia_numero_seq    SEQUENCE     �   CREATE SEQUENCE public.boletagarantia_numero_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.boletagarantia_numero_seq;
       public               postgres    false    226            n           0    0    boletagarantia_numero_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.boletagarantia_numero_seq OWNED BY public.boletagarantia.numero;
          public               postgres    false    225            �            1259    16499    depositoaplazo    TABLE       CREATE TABLE public.depositoaplazo (
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
 "   DROP TABLE public.depositoaplazo;
       public         heap r       postgres    false            �            1259    16498    depositoaplazo_id_deposito_seq    SEQUENCE     �   CREATE SEQUENCE public.depositoaplazo_id_deposito_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.depositoaplazo_id_deposito_seq;
       public               postgres    false    236            o           0    0    depositoaplazo_id_deposito_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.depositoaplazo_id_deposito_seq OWNED BY public.depositoaplazo.id_deposito;
          public               postgres    false    235            �            1259    16487 
   dividendos    TABLE     �   CREATE TABLE public.dividendos (
    id_dividendo integer NOT NULL,
    id_accion integer NOT NULL,
    monto numeric(15,2) NOT NULL,
    fecha date NOT NULL
);
    DROP TABLE public.dividendos;
       public         heap r       postgres    false            �            1259    16486    dividendos_id_dividendo_seq    SEQUENCE     �   CREATE SEQUENCE public.dividendos_id_dividendo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.dividendos_id_dividendo_seq;
       public               postgres    false    234            p           0    0    dividendos_id_dividendo_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.dividendos_id_dividendo_seq OWNED BY public.dividendos.id_dividendo;
          public               postgres    false    233            �            1259    16386    entidad    TABLE     U  CREATE TABLE public.entidad (
    id_entidad integer NOT NULL,
    rut character varying(20) NOT NULL,
    nombre character varying(100) NOT NULL,
    tipoentidad character varying(50) NOT NULL,
    contacto character varying(100),
    email character varying(100),
    fonofijo character varying(15),
    fonomovil character varying(15)
);
    DROP TABLE public.entidad;
       public         heap r       postgres    false            �            1259    16385    entidad_id_entidad_seq    SEQUENCE     �   CREATE SEQUENCE public.entidad_id_entidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.entidad_id_entidad_seq;
       public               postgres    false    218            q           0    0    entidad_id_entidad_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.entidad_id_entidad_seq OWNED BY public.entidad.id_entidad;
          public               postgres    false    217            �            1259    16395    entidadcomercial    TABLE     �   CREATE TABLE public.entidadcomercial (
    id_entidad integer NOT NULL,
    rut character varying(20) NOT NULL,
    nombre character varying(100) NOT NULL,
    tipoentidad character varying(50) NOT NULL
);
 $   DROP TABLE public.entidadcomercial;
       public         heap r       postgres    false            �            1259    16394    entidadcomercial_id_entidad_seq    SEQUENCE     �   CREATE SEQUENCE public.entidadcomercial_id_entidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.entidadcomercial_id_entidad_seq;
       public               postgres    false    220            r           0    0    entidadcomercial_id_entidad_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.entidadcomercial_id_entidad_seq OWNED BY public.entidadcomercial.id_entidad;
          public               postgres    false    219            �            1259    16423    facturas    TABLE     
  CREATE TABLE public.facturas (
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
    DROP TABLE public.facturas;
       public         heap r       postgres    false            �            1259    16422    facturas_numerofactura_seq    SEQUENCE     �   CREATE SEQUENCE public.facturas_numerofactura_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.facturas_numerofactura_seq;
       public               postgres    false    224            s           0    0    facturas_numerofactura_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.facturas_numerofactura_seq OWNED BY public.facturas.numerofactura;
          public               postgres    false    223            �            1259    16459    fondosmutuos    TABLE     �  CREATE TABLE public.fondosmutuos (
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
     DROP TABLE public.fondosmutuos;
       public         heap r       postgres    false            �            1259    16458    fondosmutuos_id_fondo_seq    SEQUENCE     �   CREATE SEQUENCE public.fondosmutuos_id_fondo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.fondosmutuos_id_fondo_seq;
       public               postgres    false    228            t           0    0    fondosmutuos_id_fondo_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.fondosmutuos_id_fondo_seq OWNED BY public.fondosmutuos.id_fondo;
          public               postgres    false    227            �            1259    16471    polizas    TABLE     �   CREATE TABLE public.polizas (
    numero integer NOT NULL,
    tipoasegurado character varying(50) NOT NULL,
    fechainicio date NOT NULL,
    fechatermino date NOT NULL,
    monto numeric(15,2) NOT NULL,
    adjuntopoliza character varying(255)
);
    DROP TABLE public.polizas;
       public         heap r       postgres    false            �            1259    16470    polizas_numero_seq    SEQUENCE     �   CREATE SEQUENCE public.polizas_numero_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.polizas_numero_seq;
       public               postgres    false    230            u           0    0    polizas_numero_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.polizas_numero_seq OWNED BY public.polizas.numero;
          public               postgres    false    229            �            1259    16416    tipoinversion    TABLE     j   CREATE TABLE public.tipoinversion (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL
);
 !   DROP TABLE public.tipoinversion;
       public         heap r       postgres    false            �            1259    16415    tipoinversion_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tipoinversion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.tipoinversion_id_seq;
       public               postgres    false    222            v           0    0    tipoinversion_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.tipoinversion_id_seq OWNED BY public.tipoinversion.id;
          public               postgres    false    221            �            1259    16520    usuarios    TABLE     �   CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombreusuario character varying(50) NOT NULL,
    "contraseña" character varying(255) NOT NULL
);
    DROP TABLE public.usuarios;
       public         heap r       postgres    false            �            1259    16519    usuarios_id_seq    SEQUENCE     �   CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.usuarios_id_seq;
       public               postgres    false    238            w           0    0    usuarios_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;
          public               postgres    false    237            �           2604    16481    accion id_accion    DEFAULT     t   ALTER TABLE ONLY public.accion ALTER COLUMN id_accion SET DEFAULT nextval('public.accion_id_accion_seq'::regclass);
 ?   ALTER TABLE public.accion ALTER COLUMN id_accion DROP DEFAULT;
       public               postgres    false    232    231    232            �           2604    16443    boletagarantia numero    DEFAULT     ~   ALTER TABLE ONLY public.boletagarantia ALTER COLUMN numero SET DEFAULT nextval('public.boletagarantia_numero_seq'::regclass);
 D   ALTER TABLE public.boletagarantia ALTER COLUMN numero DROP DEFAULT;
       public               postgres    false    225    226    226            �           2604    16547    depositoaplazo id_deposito    DEFAULT     �   ALTER TABLE ONLY public.depositoaplazo ALTER COLUMN id_deposito SET DEFAULT nextval('public.depositoaplazo_id_deposito_seq'::regclass);
 I   ALTER TABLE public.depositoaplazo ALTER COLUMN id_deposito DROP DEFAULT;
       public               postgres    false    235    236    236            �           2604    16490    dividendos id_dividendo    DEFAULT     �   ALTER TABLE ONLY public.dividendos ALTER COLUMN id_dividendo SET DEFAULT nextval('public.dividendos_id_dividendo_seq'::regclass);
 F   ALTER TABLE public.dividendos ALTER COLUMN id_dividendo DROP DEFAULT;
       public               postgres    false    233    234    234            �           2604    16389    entidad id_entidad    DEFAULT     x   ALTER TABLE ONLY public.entidad ALTER COLUMN id_entidad SET DEFAULT nextval('public.entidad_id_entidad_seq'::regclass);
 A   ALTER TABLE public.entidad ALTER COLUMN id_entidad DROP DEFAULT;
       public               postgres    false    218    217    218            �           2604    16398    entidadcomercial id_entidad    DEFAULT     �   ALTER TABLE ONLY public.entidadcomercial ALTER COLUMN id_entidad SET DEFAULT nextval('public.entidadcomercial_id_entidad_seq'::regclass);
 J   ALTER TABLE public.entidadcomercial ALTER COLUMN id_entidad DROP DEFAULT;
       public               postgres    false    219    220    220            �           2604    16426    facturas numerofactura    DEFAULT     �   ALTER TABLE ONLY public.facturas ALTER COLUMN numerofactura SET DEFAULT nextval('public.facturas_numerofactura_seq'::regclass);
 E   ALTER TABLE public.facturas ALTER COLUMN numerofactura DROP DEFAULT;
       public               postgres    false    224    223    224            �           2604    16462    fondosmutuos id_fondo    DEFAULT     ~   ALTER TABLE ONLY public.fondosmutuos ALTER COLUMN id_fondo SET DEFAULT nextval('public.fondosmutuos_id_fondo_seq'::regclass);
 D   ALTER TABLE public.fondosmutuos ALTER COLUMN id_fondo DROP DEFAULT;
       public               postgres    false    227    228    228            �           2604    16474    polizas numero    DEFAULT     p   ALTER TABLE ONLY public.polizas ALTER COLUMN numero SET DEFAULT nextval('public.polizas_numero_seq'::regclass);
 =   ALTER TABLE public.polizas ALTER COLUMN numero DROP DEFAULT;
       public               postgres    false    230    229    230            �           2604    16419    tipoinversion id    DEFAULT     t   ALTER TABLE ONLY public.tipoinversion ALTER COLUMN id SET DEFAULT nextval('public.tipoinversion_id_seq'::regclass);
 ?   ALTER TABLE public.tipoinversion ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    221    222    222            �           2604    16523    usuarios id    DEFAULT     j   ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);
 :   ALTER TABLE public.usuarios ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    238    237    238            `          0    16478    accion 
   TABLE DATA           L   COPY public.accion (id_accion, ticker, nombre, mercado, sector) FROM stdin;
    public               postgres    false    232   i�       Z          0    16440    boletagarantia 
   TABLE DATA           �   COPY public.boletagarantia (numero, id_banco, id_beneficiario, glosa, vencimiento, moneda, monto, fechaemision, estado, documento, tomada_por_empresa, tomada_por_rut) FROM stdin;
    public               postgres    false    226   ��       d          0    16499    depositoaplazo 
   TABLE DATA           v  COPY public.depositoaplazo (id_deposito, id_entidadcomercial, id_banco, fechaemision, fechavencimiento, moneda, montoinicial, montofinal, comprobante, tipodeposito, interesganado, plazo, tasainteres, reajusteganado, capitalrenovacion, fechaemisionrenovacion, tasainteresrenovacion, plazorenovacion, tasaperiodo, fechavencimientorenovacion, totalpagarrenovacion) FROM stdin;
    public               postgres    false    236   ��       b          0    16487 
   dividendos 
   TABLE DATA           K   COPY public.dividendos (id_dividendo, id_accion, monto, fecha) FROM stdin;
    public               postgres    false    234   ��       R          0    16386    entidad 
   TABLE DATA           m   COPY public.entidad (id_entidad, rut, nombre, tipoentidad, contacto, email, fonofijo, fonomovil) FROM stdin;
    public               postgres    false    218   Ղ       T          0    16395    entidadcomercial 
   TABLE DATA           P   COPY public.entidadcomercial (id_entidad, rut, nombre, tipoentidad) FROM stdin;
    public               postgres    false    220   �       X          0    16423    facturas 
   TABLE DATA           �   COPY public.facturas (numerofactura, id_corredora, fecha, tipo, cantidad, valor, subtotal, comision, gasto, adjuntofactura, id_tipoinversion, rut, preciounitario, nombreactivo) FROM stdin;
    public               postgres    false    224   (�       \          0    16459    fondosmutuos 
   TABLE DATA           �   COPY public.fondosmutuos (id_fondo, nombre, montoinvertido, rentabilidad, montofinal, id_entidad, comprobante, tiporiesgo, fechainicio, fechatermino, id_banco) FROM stdin;
    public               postgres    false    228   b�       ^          0    16471    polizas 
   TABLE DATA           i   COPY public.polizas (numero, tipoasegurado, fechainicio, fechatermino, monto, adjuntopoliza) FROM stdin;
    public               postgres    false    230   R�       V          0    16416    tipoinversion 
   TABLE DATA           3   COPY public.tipoinversion (id, nombre) FROM stdin;
    public               postgres    false    222   ��       f          0    16520    usuarios 
   TABLE DATA           D   COPY public.usuarios (id, nombreusuario, "contraseña") FROM stdin;
    public               postgres    false    238   �       x           0    0    accion_id_accion_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.accion_id_accion_seq', 1, false);
          public               postgres    false    231            y           0    0    boletagarantia_numero_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.boletagarantia_numero_seq', 2, true);
          public               postgres    false    225            z           0    0    depositoaplazo_id_deposito_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.depositoaplazo_id_deposito_seq', 4, true);
          public               postgres    false    235            {           0    0    dividendos_id_dividendo_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.dividendos_id_dividendo_seq', 1, false);
          public               postgres    false    233            |           0    0    entidad_id_entidad_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.entidad_id_entidad_seq', 23, true);
          public               postgres    false    217            }           0    0    entidadcomercial_id_entidad_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.entidadcomercial_id_entidad_seq', 19, true);
          public               postgres    false    219            ~           0    0    facturas_numerofactura_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.facturas_numerofactura_seq', 1, false);
          public               postgres    false    223                       0    0    fondosmutuos_id_fondo_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.fondosmutuos_id_fondo_seq', 11, true);
          public               postgres    false    227            �           0    0    polizas_numero_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.polizas_numero_seq', 1, false);
          public               postgres    false    229            �           0    0    tipoinversion_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.tipoinversion_id_seq', 2, true);
          public               postgres    false    221            �           0    0    usuarios_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.usuarios_id_seq', 1, true);
          public               postgres    false    237            �           2606    16483    accion accion_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.accion
    ADD CONSTRAINT accion_pkey PRIMARY KEY (id_accion);
 <   ALTER TABLE ONLY public.accion DROP CONSTRAINT accion_pkey;
       public                 postgres    false    232            �           2606    16485    accion accion_ticker_key 
   CONSTRAINT     U   ALTER TABLE ONLY public.accion
    ADD CONSTRAINT accion_ticker_key UNIQUE (ticker);
 B   ALTER TABLE ONLY public.accion DROP CONSTRAINT accion_ticker_key;
       public                 postgres    false    232            �           2606    16447 "   boletagarantia boletagarantia_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.boletagarantia
    ADD CONSTRAINT boletagarantia_pkey PRIMARY KEY (numero);
 L   ALTER TABLE ONLY public.boletagarantia DROP CONSTRAINT boletagarantia_pkey;
       public                 postgres    false    226            �           2606    16549 "   depositoaplazo depositoaplazo_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.depositoaplazo
    ADD CONSTRAINT depositoaplazo_pkey PRIMARY KEY (id_deposito);
 L   ALTER TABLE ONLY public.depositoaplazo DROP CONSTRAINT depositoaplazo_pkey;
       public                 postgres    false    236            �           2606    16492    dividendos dividendos_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.dividendos
    ADD CONSTRAINT dividendos_pkey PRIMARY KEY (id_dividendo);
 D   ALTER TABLE ONLY public.dividendos DROP CONSTRAINT dividendos_pkey;
       public                 postgres    false    234            �           2606    16391    entidad entidad_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.entidad
    ADD CONSTRAINT entidad_pkey PRIMARY KEY (id_entidad);
 >   ALTER TABLE ONLY public.entidad DROP CONSTRAINT entidad_pkey;
       public                 postgres    false    218            �           2606    16393    entidad entidad_rut_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.entidad
    ADD CONSTRAINT entidad_rut_key UNIQUE (rut);
 A   ALTER TABLE ONLY public.entidad DROP CONSTRAINT entidad_rut_key;
       public                 postgres    false    218            �           2606    16400 &   entidadcomercial entidadcomercial_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.entidadcomercial
    ADD CONSTRAINT entidadcomercial_pkey PRIMARY KEY (id_entidad);
 P   ALTER TABLE ONLY public.entidadcomercial DROP CONSTRAINT entidadcomercial_pkey;
       public                 postgres    false    220            �           2606    16402 )   entidadcomercial entidadcomercial_rut_key 
   CONSTRAINT     c   ALTER TABLE ONLY public.entidadcomercial
    ADD CONSTRAINT entidadcomercial_rut_key UNIQUE (rut);
 S   ALTER TABLE ONLY public.entidadcomercial DROP CONSTRAINT entidadcomercial_rut_key;
       public                 postgres    false    220            �           2606    16428    facturas facturas_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.facturas
    ADD CONSTRAINT facturas_pkey PRIMARY KEY (numerofactura);
 @   ALTER TABLE ONLY public.facturas DROP CONSTRAINT facturas_pkey;
       public                 postgres    false    224            �           2606    16464    fondosmutuos fondosmutuos_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.fondosmutuos
    ADD CONSTRAINT fondosmutuos_pkey PRIMARY KEY (id_fondo);
 H   ALTER TABLE ONLY public.fondosmutuos DROP CONSTRAINT fondosmutuos_pkey;
       public                 postgres    false    228            �           2606    16476    polizas polizas_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.polizas
    ADD CONSTRAINT polizas_pkey PRIMARY KEY (numero);
 >   ALTER TABLE ONLY public.polizas DROP CONSTRAINT polizas_pkey;
       public                 postgres    false    230            �           2606    16421     tipoinversion tipoinversion_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.tipoinversion
    ADD CONSTRAINT tipoinversion_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.tipoinversion DROP CONSTRAINT tipoinversion_pkey;
       public                 postgres    false    222            �           2606    16527 #   usuarios usuarios_nombreusuario_key 
   CONSTRAINT     g   ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_nombreusuario_key UNIQUE (nombreusuario);
 M   ALTER TABLE ONLY public.usuarios DROP CONSTRAINT usuarios_nombreusuario_key;
       public                 postgres    false    238            �           2606    16525    usuarios usuarios_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.usuarios DROP CONSTRAINT usuarios_pkey;
       public                 postgres    false    238            �           2620    16541 '   depositoaplazo trigger_actualizar_plazo    TRIGGER     �   CREATE TRIGGER trigger_actualizar_plazo BEFORE INSERT OR UPDATE ON public.depositoaplazo FOR EACH ROW EXECUTE FUNCTION public.actualizar_plazo();

ALTER TABLE public.depositoaplazo DISABLE TRIGGER trigger_actualizar_plazo;
 @   DROP TRIGGER trigger_actualizar_plazo ON public.depositoaplazo;
       public               postgres    false    236    239            �           2606    16448 +   boletagarantia boletagarantia_id_banco_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.boletagarantia
    ADD CONSTRAINT boletagarantia_id_banco_fkey FOREIGN KEY (id_banco) REFERENCES public.entidad(id_entidad);
 U   ALTER TABLE ONLY public.boletagarantia DROP CONSTRAINT boletagarantia_id_banco_fkey;
       public               postgres    false    218    4760    226            �           2606    16453 -   boletagarantia boletagarantia_id_cliente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.boletagarantia
    ADD CONSTRAINT boletagarantia_id_cliente_fkey FOREIGN KEY (id_beneficiario) REFERENCES public.entidadcomercial(id_entidad);
 W   ALTER TABLE ONLY public.boletagarantia DROP CONSTRAINT boletagarantia_id_cliente_fkey;
       public               postgres    false    4764    226    220            �           2606    16510 +   depositoaplazo depositoaplazo_id_banco_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.depositoaplazo
    ADD CONSTRAINT depositoaplazo_id_banco_fkey FOREIGN KEY (id_banco) REFERENCES public.entidad(id_entidad);
 U   ALTER TABLE ONLY public.depositoaplazo DROP CONSTRAINT depositoaplazo_id_banco_fkey;
       public               postgres    false    218    4760    236            �           2606    16505 -   depositoaplazo depositoaplazo_id_empresa_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.depositoaplazo
    ADD CONSTRAINT depositoaplazo_id_empresa_fkey FOREIGN KEY (id_entidadcomercial) REFERENCES public.entidadcomercial(id_entidad);
 W   ALTER TABLE ONLY public.depositoaplazo DROP CONSTRAINT depositoaplazo_id_empresa_fkey;
       public               postgres    false    4764    236    220            �           2606    16493 $   dividendos dividendos_id_accion_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dividendos
    ADD CONSTRAINT dividendos_id_accion_fkey FOREIGN KEY (id_accion) REFERENCES public.accion(id_accion);
 N   ALTER TABLE ONLY public.dividendos DROP CONSTRAINT dividendos_id_accion_fkey;
       public               postgres    false    234    232    4778            �           2606    16429 #   facturas facturas_id_corredora_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.facturas
    ADD CONSTRAINT facturas_id_corredora_fkey FOREIGN KEY (id_corredora) REFERENCES public.entidad(id_entidad);
 M   ALTER TABLE ONLY public.facturas DROP CONSTRAINT facturas_id_corredora_fkey;
       public               postgres    false    224    4760    218            �           2606    16434 '   facturas facturas_id_tipoinversion_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.facturas
    ADD CONSTRAINT facturas_id_tipoinversion_fkey FOREIGN KEY (id_tipoinversion) REFERENCES public.tipoinversion(id);
 Q   ALTER TABLE ONLY public.facturas DROP CONSTRAINT facturas_id_tipoinversion_fkey;
       public               postgres    false    222    4768    224            �           2606    16542 .   depositoaplazo fk_deposito_id_entidadcomercial    FK CONSTRAINT     �   ALTER TABLE ONLY public.depositoaplazo
    ADD CONSTRAINT fk_deposito_id_entidadcomercial FOREIGN KEY (id_entidadcomercial) REFERENCES public.entidadcomercial(id_entidad);
 X   ALTER TABLE ONLY public.depositoaplazo DROP CONSTRAINT fk_deposito_id_entidadcomercial;
       public               postgres    false    220    4764    236            �           2606    16528 '   fondosmutuos fondosmutuos_id_banco_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.fondosmutuos
    ADD CONSTRAINT fondosmutuos_id_banco_fkey FOREIGN KEY (id_banco) REFERENCES public.entidad(id_entidad);
 Q   ALTER TABLE ONLY public.fondosmutuos DROP CONSTRAINT fondosmutuos_id_banco_fkey;
       public               postgres    false    4760    228    218            �           2606    16533 2   fondosmutuos fondosmutuos_id_entidadcomercial_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.fondosmutuos
    ADD CONSTRAINT fondosmutuos_id_entidadcomercial_fkey FOREIGN KEY (id_entidad) REFERENCES public.entidadcomercial(id_entidad);
 \   ALTER TABLE ONLY public.fondosmutuos DROP CONSTRAINT fondosmutuos_id_entidadcomercial_fkey;
       public               postgres    false    4764    220    228            `      x������ � �      Z     x����J�0��ӧ8/�.'Y�zY�!J�+a �6���4z�;���i7D��"��9��g(�-92��`�Zk�#o�S@�ie��n{�jC��C]��&a�Hc��%ge�c��O'�|J�����W�X_&B�+��xT�-��}`�V+g�E,q��ߴ,���6z�]�gKݸx�g���4#55j��]UZb�A*�b�v���;98�$�UG�$��W�S��2F�����
	σ�?��,�����~�jS���z�<pW��j��ɐc�2��IE_r��.      d   �   x����j�0�g�]��d�N殥����H��9��C��r�&�6�c��>+��&�X3� ����2I���Ed"��`����~���vө��4]�ti/��~��~���������ڷ���|�Ŋ�����9N4n8l��B�f�%DW7LA�l�lq����J���;���QvlY���07�5�c] �r�W�$�MS� �)�>���xY|��_hZ��Z�e��5�C��h�t���_EY$��͹2�� �0�}      b      x������ � �      R     x�u�An� �5>�/Њ��K���ʵ#�RRe��֒����b�*qc�X6�c>`��rɚh���޻��.�˫�&ocm����}������Yt/���p:	Xe:����\e�Οo�
�{���7�i��p�v�T�ٜ�䦲*G%�E����QNe�\%M��5�v(�;&�����SӺ*���W��N�*�)%��嶺���h�@�}q�t�t��)k���_ ����+$i"���|�	wz̲�]��      T   /  x�e��N� ���)x7@�m����ej��b�L��<z��#��dc�nk@�����$��3���\T�I�8�W#PX5�^^�ow����.51��h\��^��#�'t�K39��1-���0mQ�$!5c��Y#��LP</��n�B��������)i���o��P�yc�P\M2yH�u��_�y|�?��Lq��RW$����U��t��x�khZr�gh�E)�^V5�蠥~���%���V��da��;�ÇŞ��۟��$y�K)I��p�F�1g1ʇ��ؼ;��a��nEQ� ���      X   *  x����N�@���w��;�s�U�HL4zaH̆��D-)���]�65j�df�|�� yV���H9Z�=|Ǡh���}i ����V�+S� ��S���iN��!�Ʀ�B;���mڏS1�:xck�R�v��>>�V�O�����&r@9�	��I&�G&�uI�å���a�Z��V�}�i�9�����殮��Ԭlt�sĜ��#�AN1w�����nM���"j��KT�̶�e�9��dy�:+i.��tZ��$�t�>��N^^�����9%�tkl����^��^�n�,˾ a��      \   �   x���͊�0�u�y�֛�غLd:�Dj�YR�g"4}M&��������m����ɪ��N����5%h0��|/��M�ݰ8��N�~F3����{wF۾�hĀA 4����G�q��b߈�*�H����&�)�#���2@m�>�0/օlٔ����&�u�9.m�ڗ�m)�d���c��W�H)���"+�9�s��yl�[N� �G��5>����x�      ^   V   x��1
�0 �9�K�$���/8�[�P�и�zћ.��1�RK>-��*���ׁDI���E+��[�b�]�<q��ĵt�����t      V      x�3�t��-(J�2�K�+I����� F��      f   �   x��;�0 й=3r��N:r�,�'��� 數��z���ڞ��P�.uI��~��k9��v��v��0� �V]љ��)˨*�Z�2E����=CSKR�(��d����zj �D���QV(#e�A���PD�L���q��?��0�     