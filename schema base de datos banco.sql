--
-- PostgreSQL database dump
--

\restrict fW3XprF2sasyOfQgfxqEQAwCzBZSOh07d9gsTH53R0wEh20dd0UpmDp1IkeCdLG

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-03-20 18:45:51

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
-- TOC entry 234 (class 1255 OID 16532)
-- Name: aumentar_saldo_destino(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.aumentar_saldo_destino() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

IF NEW.Estado_Transferencia = 'Ejecutada' THEN

UPDATE Cuenta
SET Saldo_Actual = Saldo_Actual + NEW.Monto
WHERE Numero_Cuenta = NEW.Cuenta_Destino;

END IF;

RETURN NEW;
END;
$$;


ALTER FUNCTION public.aumentar_saldo_destino() OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 16530)
-- Name: descontar_saldo_origen(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.descontar_saldo_origen() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

IF NEW.Estado_Transferencia = 'Ejecutada' THEN

UPDATE Cuenta
SET Saldo_Actual = Saldo_Actual - NEW.Monto
WHERE Numero_Cuenta = NEW.Cuenta_Origen;

END IF;

RETURN NEW;
END;
$$;


ALTER FUNCTION public.descontar_saldo_origen() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16534)
-- Name: evitar_saldo_negativo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.evitar_saldo_negativo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

IF NEW.Saldo_Actual < 0 THEN
RAISE EXCEPTION 'El saldo no puede ser negativo';
END IF;

RETURN NEW;
END;
$$;


ALTER FUNCTION public.evitar_saldo_negativo() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 16536)
-- Name: fecha_apertura_cuenta(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fecha_apertura_cuenta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

IF NEW.Fecha_Apertura IS NULL THEN
NEW.Fecha_Apertura = CURRENT_DATE;
END IF;

RETURN NEW;
END;
$$;


ALTER FUNCTION public.fecha_apertura_cuenta() OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 16528)
-- Name: fecha_aprobacion_transferencia(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fecha_aprobacion_transferencia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

IF NEW.Estado_Transferencia = 'Ejecutada' THEN
NEW.Fecha_Aprobacion = NOW();
END IF;

RETURN NEW;
END;
$$;


ALTER FUNCTION public.fecha_aprobacion_transferencia() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 16526)
-- Name: validar_saldo_transferencia(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validar_saldo_transferencia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
saldo_actual NUMERIC(15,2);
BEGIN

SELECT Saldo_Actual INTO saldo_actual
FROM Cuenta
WHERE Numero_Cuenta = NEW.Cuenta_Origen;

IF saldo_actual < NEW.Monto THEN
RAISE EXCEPTION 'Saldo insuficiente para realizar la transferencia';
END IF;

RETURN NEW;
END;
$$;


ALTER FUNCTION public.validar_saldo_transferencia() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 16424)
-- Name: cliente_empresa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cliente_empresa (
    id_empresa integer NOT NULL,
    razon_social character varying(150) NOT NULL,
    numero_identificacion_fiscal character varying(20) NOT NULL,
    correo_electronico character varying(100) NOT NULL,
    telefono character varying(15) NOT NULL,
    direccion character varying(150) NOT NULL,
    id_representante integer NOT NULL
);


ALTER TABLE public.cliente_empresa OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16423)
-- Name: cliente_empresa_id_empresa_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cliente_empresa_id_empresa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cliente_empresa_id_empresa_seq OWNER TO postgres;

--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 223
-- Name: cliente_empresa_id_empresa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cliente_empresa_id_empresa_seq OWNED BY public.cliente_empresa.id_empresa;


--
-- TOC entry 222 (class 1259 OID 16403)
-- Name: cliente_persona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cliente_persona (
    id_cliente integer NOT NULL,
    nombre_completo character varying(100) NOT NULL,
    numero_identificacion character varying(20) NOT NULL,
    correo_electronico character varying(100) NOT NULL,
    telefono character varying(15) NOT NULL,
    fecha_nacimiento date NOT NULL,
    direccion character varying(150) NOT NULL
);


ALTER TABLE public.cliente_persona OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16402)
-- Name: cliente_persona_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cliente_persona_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cliente_persona_id_cliente_seq OWNER TO postgres;

--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 221
-- Name: cliente_persona_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cliente_persona_id_cliente_seq OWNED BY public.cliente_persona.id_cliente;


--
-- TOC entry 226 (class 1259 OID 16453)
-- Name: cuenta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cuenta (
    numero_cuenta character varying(20) NOT NULL,
    tipo_cuenta character varying(20),
    id_titular integer NOT NULL,
    saldo_actual numeric(15,2) DEFAULT 0,
    moneda character varying(10) DEFAULT 'COP'::character varying,
    estado_cuenta character varying(20),
    fecha_apertura date NOT NULL,
    CONSTRAINT cuenta_estado_cuenta_check CHECK (((estado_cuenta)::text = ANY ((ARRAY['Activa'::character varying, 'Bloqueada'::character varying, 'Cancelada'::character varying])::text[]))),
    CONSTRAINT cuenta_tipo_cuenta_check CHECK (((tipo_cuenta)::text = ANY ((ARRAY['Ahorros'::character varying, 'Corriente'::character varying, 'Personal'::character varying, 'Empresarial'::character varying])::text[])))
);


ALTER TABLE public.cuenta OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16471)
-- Name: prestamo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prestamo (
    id_prestamo integer NOT NULL,
    tipo_prestamo character varying(30) NOT NULL,
    id_cliente_solicitante integer NOT NULL,
    monto_solicitado numeric(15,2) NOT NULL,
    monto_aprobado numeric(15,2),
    tasa_interes numeric(5,2),
    plazo_meses integer,
    estado_prestamo character varying(20),
    fecha_aprobacion date,
    fecha_desembolso date,
    cuenta_destino_desembolso character varying(20),
    CONSTRAINT prestamo_estado_prestamo_check CHECK (((estado_prestamo)::text = ANY ((ARRAY['En estudio'::character varying, 'Aprobado'::character varying, 'Rechazado'::character varying, 'Desembolsado'::character varying])::text[])))
);


ALTER TABLE public.prestamo OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16470)
-- Name: prestamo_id_prestamo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prestamo_id_prestamo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prestamo_id_prestamo_seq OWNER TO postgres;

--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 227
-- Name: prestamo_id_prestamo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prestamo_id_prestamo_seq OWNED BY public.prestamo.id_prestamo;


--
-- TOC entry 225 (class 1259 OID 16444)
-- Name: producto_bancario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.producto_bancario (
    codigo_producto character varying(20) NOT NULL,
    nombre_producto character varying(100) NOT NULL,
    categoria character varying(50) NOT NULL,
    requiere_aprobacion boolean NOT NULL
);


ALTER TABLE public.producto_bancario OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16493)
-- Name: transferencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transferencia (
    id_transferencia integer NOT NULL,
    cuenta_origen character varying(20) NOT NULL,
    cuenta_destino character varying(20) NOT NULL,
    monto numeric(15,2),
    fecha_creacion timestamp without time zone NOT NULL,
    fecha_aprobacion timestamp without time zone,
    id_usuario_creador integer NOT NULL,
    id_usuario_aprobador integer,
    estado_transferencia character varying(30),
    CONSTRAINT transferencia_estado_transferencia_check CHECK (((estado_transferencia)::text = ANY ((ARRAY['En espera de aprobación'::character varying, 'Ejecutada'::character varying, 'Rechazada'::character varying, 'Vencida'::character varying])::text[]))),
    CONSTRAINT transferencia_monto_check CHECK ((monto > (0)::numeric))
);


ALTER TABLE public.transferencia OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16492)
-- Name: transferencia_id_transferencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transferencia_id_transferencia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transferencia_id_transferencia_seq OWNER TO postgres;

--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 229
-- Name: transferencia_id_transferencia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transferencia_id_transferencia_seq OWNED BY public.transferencia.id_transferencia;


--
-- TOC entry 220 (class 1259 OID 16387)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    nombre_completo character varying(100) NOT NULL,
    id_identificacion character varying(20) NOT NULL,
    correo_electronico character varying(100) NOT NULL,
    telefono character varying(15) NOT NULL,
    fecha_nacimiento date,
    direccion character varying(150),
    rol_sistema character varying(50) NOT NULL,
    estado_usuario character varying(20),
    CONSTRAINT usuario_estado_usuario_check CHECK (((estado_usuario)::text = ANY ((ARRAY['Activo'::character varying, 'Inactivo'::character varying, 'Bloqueado'::character varying])::text[])))
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16386)
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- TOC entry 4892 (class 2604 OID 16427)
-- Name: cliente_empresa id_empresa; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente_empresa ALTER COLUMN id_empresa SET DEFAULT nextval('public.cliente_empresa_id_empresa_seq'::regclass);


--
-- TOC entry 4891 (class 2604 OID 16406)
-- Name: cliente_persona id_cliente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente_persona ALTER COLUMN id_cliente SET DEFAULT nextval('public.cliente_persona_id_cliente_seq'::regclass);


--
-- TOC entry 4895 (class 2604 OID 16474)
-- Name: prestamo id_prestamo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamo ALTER COLUMN id_prestamo SET DEFAULT nextval('public.prestamo_id_prestamo_seq'::regclass);


--
-- TOC entry 4896 (class 2604 OID 16496)
-- Name: transferencia id_transferencia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transferencia ALTER COLUMN id_transferencia SET DEFAULT nextval('public.transferencia_id_transferencia_seq'::regclass);


--
-- TOC entry 4890 (class 2604 OID 16390)
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- TOC entry 4912 (class 2606 OID 16438)
-- Name: cliente_empresa cliente_empresa_numero_identificacion_fiscal_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente_empresa
    ADD CONSTRAINT cliente_empresa_numero_identificacion_fiscal_key UNIQUE (numero_identificacion_fiscal);


--
-- TOC entry 4914 (class 2606 OID 16436)
-- Name: cliente_empresa cliente_empresa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente_empresa
    ADD CONSTRAINT cliente_empresa_pkey PRIMARY KEY (id_empresa);


--
-- TOC entry 4908 (class 2606 OID 16417)
-- Name: cliente_persona cliente_persona_numero_identificacion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente_persona
    ADD CONSTRAINT cliente_persona_numero_identificacion_key UNIQUE (numero_identificacion);


--
-- TOC entry 4910 (class 2606 OID 16415)
-- Name: cliente_persona cliente_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente_persona
    ADD CONSTRAINT cliente_persona_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 4918 (class 2606 OID 16464)
-- Name: cuenta cuenta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cuenta
    ADD CONSTRAINT cuenta_pkey PRIMARY KEY (numero_cuenta);


--
-- TOC entry 4920 (class 2606 OID 16481)
-- Name: prestamo prestamo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamo
    ADD CONSTRAINT prestamo_pkey PRIMARY KEY (id_prestamo);


--
-- TOC entry 4916 (class 2606 OID 16452)
-- Name: producto_bancario producto_bancario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto_bancario
    ADD CONSTRAINT producto_bancario_pkey PRIMARY KEY (codigo_producto);


--
-- TOC entry 4922 (class 2606 OID 16505)
-- Name: transferencia transferencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transferencia
    ADD CONSTRAINT transferencia_pkey PRIMARY KEY (id_transferencia);


--
-- TOC entry 4904 (class 2606 OID 16401)
-- Name: usuario usuario_id_identificacion_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_id_identificacion_key UNIQUE (id_identificacion);


--
-- TOC entry 4906 (class 2606 OID 16399)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4934 (class 2620 OID 16533)
-- Name: transferencia trg_aumentar_saldo_destino; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_aumentar_saldo_destino AFTER INSERT ON public.transferencia FOR EACH ROW EXECUTE FUNCTION public.aumentar_saldo_destino();


--
-- TOC entry 4935 (class 2620 OID 16531)
-- Name: transferencia trg_descontar_saldo_origen; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_descontar_saldo_origen AFTER INSERT ON public.transferencia FOR EACH ROW EXECUTE FUNCTION public.descontar_saldo_origen();


--
-- TOC entry 4932 (class 2620 OID 16535)
-- Name: cuenta trg_evitar_saldo_negativo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_evitar_saldo_negativo BEFORE UPDATE ON public.cuenta FOR EACH ROW EXECUTE FUNCTION public.evitar_saldo_negativo();


--
-- TOC entry 4933 (class 2620 OID 16537)
-- Name: cuenta trg_fecha_apertura_cuenta; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_fecha_apertura_cuenta BEFORE INSERT ON public.cuenta FOR EACH ROW EXECUTE FUNCTION public.fecha_apertura_cuenta();


--
-- TOC entry 4936 (class 2620 OID 16529)
-- Name: transferencia trg_fecha_aprobacion_transferencia; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_fecha_aprobacion_transferencia BEFORE INSERT ON public.transferencia FOR EACH ROW EXECUTE FUNCTION public.fecha_aprobacion_transferencia();


--
-- TOC entry 4937 (class 2620 OID 16527)
-- Name: transferencia trg_validar_saldo_transferencia; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validar_saldo_transferencia BEFORE INSERT ON public.transferencia FOR EACH ROW EXECUTE FUNCTION public.validar_saldo_transferencia();


--
-- TOC entry 4924 (class 2606 OID 16439)
-- Name: cliente_empresa cliente_empresa_id_representante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente_empresa
    ADD CONSTRAINT cliente_empresa_id_representante_fkey FOREIGN KEY (id_representante) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4923 (class 2606 OID 16418)
-- Name: cliente_persona cliente_persona_numero_identificacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente_persona
    ADD CONSTRAINT cliente_persona_numero_identificacion_fkey FOREIGN KEY (numero_identificacion) REFERENCES public.usuario(id_identificacion);


--
-- TOC entry 4925 (class 2606 OID 16465)
-- Name: cuenta cuenta_id_titular_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cuenta
    ADD CONSTRAINT cuenta_id_titular_fkey FOREIGN KEY (id_titular) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4926 (class 2606 OID 16487)
-- Name: prestamo prestamo_cuenta_destino_desembolso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamo
    ADD CONSTRAINT prestamo_cuenta_destino_desembolso_fkey FOREIGN KEY (cuenta_destino_desembolso) REFERENCES public.cuenta(numero_cuenta);


--
-- TOC entry 4927 (class 2606 OID 16482)
-- Name: prestamo prestamo_id_cliente_solicitante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamo
    ADD CONSTRAINT prestamo_id_cliente_solicitante_fkey FOREIGN KEY (id_cliente_solicitante) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4928 (class 2606 OID 16511)
-- Name: transferencia transferencia_cuenta_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transferencia
    ADD CONSTRAINT transferencia_cuenta_destino_fkey FOREIGN KEY (cuenta_destino) REFERENCES public.cuenta(numero_cuenta);


--
-- TOC entry 4929 (class 2606 OID 16506)
-- Name: transferencia transferencia_cuenta_origen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transferencia
    ADD CONSTRAINT transferencia_cuenta_origen_fkey FOREIGN KEY (cuenta_origen) REFERENCES public.cuenta(numero_cuenta);


--
-- TOC entry 4930 (class 2606 OID 16521)
-- Name: transferencia transferencia_id_usuario_aprobador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transferencia
    ADD CONSTRAINT transferencia_id_usuario_aprobador_fkey FOREIGN KEY (id_usuario_aprobador) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4931 (class 2606 OID 16516)
-- Name: transferencia transferencia_id_usuario_creador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transferencia
    ADD CONSTRAINT transferencia_id_usuario_creador_fkey FOREIGN KEY (id_usuario_creador) REFERENCES public.usuario(id_usuario);


-- Completed on 2026-03-20 18:45:51

--
-- PostgreSQL database dump complete
--

\unrestrict fW3XprF2sasyOfQgfxqEQAwCzBZSOh07d9gsTH53R0wEh20dd0UpmDp1IkeCdLG

