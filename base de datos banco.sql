--
-- PostgreSQL database dump
--

\restrict s3hGCII0gW5eNOHHAgexCmPlOmX8gwv4teqccZWXYDyylbaBCVES0FiobF4Cv9I

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-03-20 18:42:23

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
-- TOC entry 5090 (class 0 OID 16424)
-- Dependencies: 224
-- Data for Name: cliente_empresa; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cliente_empresa VALUES (1, 'Tech Solutions SAS', '9001001', 'contacto@tech.com', '3101111111', 'Medellin', 1);
INSERT INTO public.cliente_empresa VALUES (2, 'Global Finance Ltda', '9001002', 'info@global.com', '3102222222', 'Bogota', 2);


--
-- TOC entry 5088 (class 0 OID 16403)
-- Dependencies: 222
-- Data for Name: cliente_persona; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cliente_persona VALUES (1, 'Juan Perez', '1003', 'juan@correo.com', '3003333333', '1988-03-20', 'Cali');
INSERT INTO public.cliente_persona VALUES (2, 'Ana Torres', '1004', 'ana@correo.com', '3004444444', '1995-11-12', 'Barranquilla');
INSERT INTO public.cliente_persona VALUES (3, 'Miguel Castro', '1005', 'miguel@correo.com', '3005555555', '1987-09-05', 'Cartagena');


--
-- TOC entry 5092 (class 0 OID 16453)
-- Dependencies: 226
-- Data for Name: cuenta; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cuenta VALUES ('200001', 'Ahorros', 3, 1000000.00, 'COP', 'Activa', '2024-01-10');
INSERT INTO public.cuenta VALUES ('200002', 'Corriente', 4, 500000.00, 'COP', 'Activa', '2024-02-05');
INSERT INTO public.cuenta VALUES ('200003', 'Personal', 5, 800000.00, 'COP', 'Activa', '2024-03-12');
INSERT INTO public.cuenta VALUES ('200004', 'Empresarial', 1, 2000000.00, 'COP', 'Activa', '2024-01-15');
INSERT INTO public.cuenta VALUES ('200005', 'Ahorros', 2, 300000.00, 'COP', 'Activa', '2024-02-20');
INSERT INTO public.cuenta VALUES ('200006', 'Corriente', 6, 700000.00, 'COP', 'Activa', '2024-03-01');


--
-- TOC entry 5094 (class 0 OID 16471)
-- Dependencies: 228
-- Data for Name: prestamo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.prestamo VALUES (1, 'Personal', 3, 5000000.00, 5000000.00, 12.50, 24, 'Aprobado', '2024-05-01', NULL, '200001');
INSERT INTO public.prestamo VALUES (2, 'Vehiculo', 4, 20000000.00, 18000000.00, 10.20, 60, 'Aprobado', '2024-05-05', NULL, '200002');
INSERT INTO public.prestamo VALUES (3, 'Hipotecario', 5, 150000000.00, NULL, 9.50, 180, 'En estudio', NULL, NULL, NULL);


--
-- TOC entry 5091 (class 0 OID 16444)
-- Dependencies: 225
-- Data for Name: producto_bancario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.producto_bancario VALUES ('P001', 'Cuenta Ahorros', 'Cuenta', false);
INSERT INTO public.producto_bancario VALUES ('P002', 'Cuenta Corriente', 'Cuenta', false);
INSERT INTO public.producto_bancario VALUES ('P003', 'Prestamo Personal', 'Prestamo', true);
INSERT INTO public.producto_bancario VALUES ('P004', 'Prestamo Hipotecario', 'Prestamo', true);
INSERT INTO public.producto_bancario VALUES ('P005', 'Transferencias', 'Servicio', false);


--
-- TOC entry 5096 (class 0 OID 16493)
-- Dependencies: 230
-- Data for Name: transferencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.transferencia VALUES (1, '200001', '200002', 200000.00, '2024-06-01 10:00:00', NULL, 1, 2, 'Ejecutada');
INSERT INTO public.transferencia VALUES (2, '200002', '200003', 150000.00, '2024-06-02 11:00:00', NULL, 2, 1, 'Ejecutada');
INSERT INTO public.transferencia VALUES (3, '200003', '200004', 100000.00, '2024-06-03 09:00:00', NULL, 3, NULL, 'En espera de aprobación');
INSERT INTO public.transferencia VALUES (4, '200004', '200005', 300000.00, '2024-06-04 15:00:00', NULL, 4, 1, 'Ejecutada');


--
-- TOC entry 5086 (class 0 OID 16387)
-- Dependencies: 220
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usuario VALUES (1, 'Carlos Ramirez', '1001', 'carlos@correo.com', '3001111111', '1990-05-10', 'Medellin', 'Administrador', 'Activo');
INSERT INTO public.usuario VALUES (2, 'Laura Gomez', '1002', 'laura@correo.com', '3002222222', '1992-07-15', 'Bogota', 'Cajero', 'Activo');
INSERT INTO public.usuario VALUES (3, 'Juan Perez', '1003', 'juan@correo.com', '3003333333', '1988-03-20', 'Cali', 'Cliente', 'Activo');
INSERT INTO public.usuario VALUES (4, 'Ana Torres', '1004', 'ana@correo.com', '3004444444', '1995-11-12', 'Barranquilla', 'Cliente', 'Activo');
INSERT INTO public.usuario VALUES (5, 'Miguel Castro', '1005', 'miguel@correo.com', '3005555555', '1987-09-05', 'Cartagena', 'Cliente', 'Activo');
INSERT INTO public.usuario VALUES (6, 'Sofia Martinez', '1006', 'sofia@correo.com', '3006666666', '1993-08-18', 'Bucaramanga', 'Cliente', 'Activo');


--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 223
-- Name: cliente_empresa_id_empresa_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cliente_empresa_id_empresa_seq', 2, true);


--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 221
-- Name: cliente_persona_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cliente_persona_id_cliente_seq', 3, true);


--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 227
-- Name: prestamo_id_prestamo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prestamo_id_prestamo_seq', 3, true);


--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 229
-- Name: transferencia_id_transferencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transferencia_id_transferencia_seq', 5, true);


--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 6, true);


-- Completed on 2026-03-20 18:42:24

--
-- PostgreSQL database dump complete
--

\unrestrict s3hGCII0gW5eNOHHAgexCmPlOmX8gwv4teqccZWXYDyylbaBCVES0FiobF4Cv9I

