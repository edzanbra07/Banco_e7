# 10. Alineacion de madurez tecnica con referencia comparativa

## Proposito

Este documento transforma la comparacion tecnica con `clinica_SDD_BD-main` en un plan de evolucion concreto para `BANCO_SDD_BD`.

La referencia clinica se usa unicamente como guia de madurez arquitectonica, operativa y documental. No se copia logica, tablas, endpoints ni estructuras de dominio, porque el banco conserva su identidad financiera propia.

## Objetivo de madurez

El proyecto bancario debe alcanzar el mismo nivel de disciplina tecnica que la referencia comparativa en estos ejes:

- arquitectura por dominios y casos de uso,
- seguridad persistida y basada en roles reales,
- contratos formales de API,
- migraciones orquestadas y trazables,
- validaciones e invariantes bancarias completas,
- auditoria homogena y correlacionada,
- documentacion SDD precisa y sincronizada,
- operacion y performance endurecidas,
- consistencia de nombres, contratos y errores.

## Principio rector

Todo cambio debe reinterpretarse para el dominio bancario.

- No se replica la clinica.
- No se trasladan entidades clinicas.
- No se copian nombres, flujos ni reglas ajenas al banco.
- Solo se adopta la madurez tecnica: orden, trazabilidad, modularidad y disciplina operativa.

## Comparacion tecnica sintetica

### 1. Arquitectura backend

La referencia comparativa organiza el backend por contextos funcionales, use cases por rol y servicios especializados. Banco ya tiene una separacion tecnica aceptable, pero sigue mas cerca de controller/service/repository que de una arquitectura por contextos bancarios.

#### Brecha de Banco

- demasiada dependencia de estructura tecnica generalista;
- casos de uso bancarios distribuidos sin frontera explicita por contexto;
- poca diferenciacion entre dominio, aplicacion, infraestructura y seguridad;
- contratos entre capas menos formalizados que en la referencia.

#### Evolucion requerida

- separar Banco por bounded contexts bancarios:
  - identidad y acceso,
  - clientes,
  - cuentas,
  - transferencias,
  - creditos,
  - pagos,
  - solicitudes,
  - delegaciones,
  - asignacion comercial,
  - auditoria,
  - reportes,
  - operacion tecnica;
- definir casos de uso explicitos por flujo bancario;
- limitar los servicios genericos a soporte tecnico real;
- formalizar una capa de aplicacion por contexto.

### 2. Seguridad y autenticacion

La referencia comparativa persiste usuarios y roles del negocio, con autorizacion alineada al contexto funcional. Banco aun tiene una autentificacion base util, pero no esta completamente persistida ni alineada al modelo bancario real.

#### Brecha de Banco

- autenticacion en memoria en la capa actual de ejemplo;
- roles funcionales no totalmente persistidos en BD;
- autorizacion aun demasiado tecnica;
- falta trazabilidad por sesion y operacion mas granular.

#### Evolucion requerida

- persistir usuarios, roles, estados y permisos en MySQL;
- alinear JWT con usuarios reales de negocio;
- reforzar expiracion, renovacion y control granular;
- registrar trazabilidad por sesion, actor, rol, operacion y entidad afectada;
- usar privilegios minimos y vistas/SPs para reduccion de superficie de acceso.

### 3. Contrato formal de API

La referencia comparativa define firmas de API, responses estandarizadas y contratos por modulo. Banco tiene controladores y respuestas consistentes, pero necesita una especificacion formal equivalente.

#### Brecha de Banco

- endpoints documentados de forma funcional, pero no como mapa formal completo;
- respuestas y errores no siempre descritos por contrato;
- falta una vista unica de requests, responses, codigos HTTP y traceability por endpoint.

#### Evolucion requerida

- crear un mapa formal de endpoints bancarios;
- estandarizar requests, responses, errores y codigos HTTP;
- documentar payloads, correlacion y `trace_id`;
- distinguir errores de validacion, negocio, autorizacion y sistema;
- mantener un formato de respuesta global estable.

### 4. SQL y migraciones

La referencia comparativa incorpora un orquestador de migracion, log de ejecucion y orden canonical. Banco tiene scripts muy completos, pero le falta un mecanismo orquestado y trazable del mismo nivel.

#### Brecha de Banco

- scripts separados, pero sin orquestador canónico;
- archivo legacy coexistiendo con el flujo principal;
- validacion post-migracion menos formalizada;
- sin registro normalizado de ejecucion por script.

#### Evolucion requerida

- crear `migrate.sql` canónico para Banco;
- registrar ejecucion, estado y duracion por script;
- separar claramente scripts legacy del flujo oficial;
- endurecer `sql_mode`, timezone y validacion de sesion;
- definir rollback o recuperacion operativa cuando aplique.

### 5. Validaciones e invariantes bancarias

La referencia comparativa formaliza invariantes por flujo. Banco ya valida mucho en triggers y SPs, pero debe elevar la documentacion de invariantes a nivel mas exhaustivo y preciso.

#### Invariantes bancarias a documentar y mantener

- saldo disponible y suficiencia real;
- ownership de cliente, cuenta, empresa y usuario;
- concurrencia y bloqueos de fila;
- aprobacion simple y doble aprobacion segun flujo;
- estados validos y transiciones permitidas;
- consistencia transaccional de saldo y ledger;
- reversibilidad controlada de operaciones;
- antifraude basico por incompatibilidad de rol, entidad o ventana temporal.

#### Evolucion requerida

- documentar invariantes funcionales por agregado bancario;
- ligar cada regla a trigger, SP o constraint;
- evitar reglas criticas dispersas en la capa cliente;
- reforzar mensajes de error funcionales y codigos estables.

### 6. Auditoria y observabilidad

La referencia comparativa homogeneiza eventos, payloads y trazabilidad. Banco ya tiene bitacora y trazabilidad, pero necesita unificar el lenguaje operativo de toda la solucion.

#### Brecha de Banco

- trace ids y mensajes no siempre documentados con la misma precision;
- auditoria funcional correcta, pero no completamente estandarizada en contrato;
- trazabilidad operativa repartida entre SQL, backend y documentacion.

#### Evolucion requerida

- unificar `trace_id` como correlacion transversal;
- registrar actor, rol, entidad, evento y payload JSON;
- estandarizar bitacoras de negocio y tecnicas;
- documentar eventos auditables por flujo;
- separar auditoria funcional de logs tecnicos sin perder correlacion.

### 7. Modularizacion y documentacion

La referencia comparativa divide claramente dominio, aplicacion, infraestructura, seguridad y contratos. Banco documenta muy bien el dominio, pero necesita una frontera mas nitida entre capas.

#### Brecha de Banco

- documentacion SDD correcta, pero menos formal en contratos;
- backend y SQL no siempre descritos con el mismo grado de detalle;
- faltan guias de uso por modulo y por flujo bancario.

#### Evolucion requerida

- llevar la documentacion Banco al nivel de precision operacional de la referencia;
- mantener lenguaje exclusivamente bancario;
- documentar correspondencia entre casos de uso, SPs, triggers, vistas y seguridad;
- establecer un indice canonico entre SDD, SQL y backend.

### 8. Operacion y performance

La referencia comparativa endurece la configuracion operativa y el proceso de despliegue. Banco ya define indices y transacciones, pero puede subir la disciplina fisica y operativa.

#### Brecha de Banco

- menor formalizacion de entorno, despliegue y validacion post-cambio;
- necesidad de un proceso canónico para migracion y control de versiones;
- falta documentar con mas precision los puntos de bloqueo y el costo de consultas criticas.

#### Evolucion requerida

- documentar timezone, sql_mode y prerequisitos de entorno;
- mantener una tabla clara de indices y patrones de acceso;
- revisar locking y concurrencia en los flujos mas sensibles;
- definir pruebas de migracion, validacion y handoff operacional.

## Arquitectura objetivo de Banco

Banco debe evolucionar hacia una arquitectura por contextos bancarios con estas capas:

- dominio: reglas, entidades conceptuales, invariantes y vocabulario;
- aplicacion: casos de uso bancarios y orquestacion de flujos;
- infraestructura: acceso a DB, security adapters, persistencia y clientes externos;
- seguridad: autenticacion, autorizacion, roles, tokens y sesiones;
- persistencia: entidades JPA, repositorios y adapters SQL;
- contratos: DTOs, requests, responses y errores;
- auditoria: trazabilidad, bitacoras y correlacion;
- operacion: migracion, semillas, validacion y observabilidad.

## Modulos bancarios recomendados

- identidad y acceso;
- clientes;
- cuentas y movimientos;
- transferencias;
- creditos;
- pagos masivos;
- solicitudes comerciales;
- delegaciones;
- asignacion comercial;
- auditoria y bitacora;
- reportes de lectura;
- soporte tecnico y mantenimiento.

## Casos de uso bancarios a explicitar

- alta de cliente persona;
- alta de cliente empresa;
- apertura de cuenta;
- cambio de estado de cuenta;
- solicitud de prestamo;
- aprobacion y rechazo de prestamo;
- desembolso de prestamo;
- creacion de transferencia;
- aprobacion y rechazo de transferencia;
- ejecucion de transferencia;
- vencimiento tecnico o controlado de transferencias;
- creacion de pago masivo;
- adicion de detalles;
- aprobacion, rechazo y ejecucion de lote;
- consulta de cartera por usuario o empresa;
- delegacion y revocacion de permisos;
- consulta de auditoria por rango.

## Contratos operativos minimos

Todo flujo bancario sensible debe documentar:

- entrada;
- salida estandar;
- codigo de negocio;
- excepciones esperadas;
- transaccion;
- tablas impactadas;
- reglas de ownership;
- roles autorizados;
- eventos auditables;
- `trace_id`;
- criterio de rollback.

## SQL canonico recomendado

El paquete SQL de Banco debe consolidarse en un flujo canónico con este orden:

1. esquema y sesion;
2. catalogos;
3. tablas;
4. indices;
5. triggers;
6. procedimientos;
7. vistas;
8. auditoria;
9. seguridad;
10. datos semilla;
11. pruebas y validacion post-migracion.

## Scripts legacy

Los scripts heredados o combinados deben quedar claramente marcados fuera del flujo principal para evitar ambiguedad operativa.

## Backlog priorizado

### Fase 1 — Base estructural

- reorganizar documentación SDD para hacer visible la arquitectura por contextos;
- establecer un mapa de casos de uso bancarios;
- documentar contratos estandar de SPs y errores;
- definir el flujo canónico de migración.

### Fase 2 — Backend y seguridad

- migrar autenticación a usuarios persistidos en BD;
- alinear roles Java con roles bancarios reales;
- separar use cases bancarios de infraestructura;
- reforzar trazabilidad por operación y por sesión.

### Fase 3 — SQL e integridad

- endurecer validaciones por agregado;
- revisar invariantes de saldo, ownership, estados y concurrencia;
- homogeneizar mensajes y codigos de salida;
- consolidar auditoria y ledger inmutable.

### Fase 4 — Operación y calidad

- crear migracion canónica con log;
- formalizar pruebas de post-despliegue;
- documentar indices, locking y patrones de acceso;
- consolidar observabilidad y handoff.

## Criterios de aceptacion

Banco se considera alineado en madurez con la referencia comparativa cuando:

- el backend está organizado por contextos bancarios y casos de uso reales;
- la seguridad persiste usuarios y roles del negocio;
- la API tiene contratos documentados y consistentes;
- el SQL tiene migración canónica, trazable y ordenada;
- las validaciones bancarias están documentadas y aplicadas en la capa correcta;
- la auditoría conserva correlación transversal;
- la operación está endurecida y reproducible;
- la documentación SDD describe el sistema de punta a punta sin ambigüedad.

## Nota final

La meta no es parecerse a la clínica, sino alcanzar el mismo nivel de madurez técnica. Banco debe conservar su identidad financiera, su lenguaje bancario y sus invariantes propias, adoptando únicamente la disciplina arquitectonica y operativa que la referencia comparativa demuestra.