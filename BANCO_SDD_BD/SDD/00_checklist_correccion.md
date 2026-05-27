# Checklist maestro de correccion SDD

## 1. Alcance y premisas

- [ ] Confirmar que el alcance bancario esta delimitado sin ambiguedades.
- [ ] Explicitar fuera de alcance, supuestos y restricciones de diseño.
- [ ] Alinear la documentacion con la solucion SQL real y con el README raiz.

## 2. Contexto y principios

- [ ] Definir el sistema como plataforma bancaria transaccional primero.
- [ ] Separar entidades, agregados, invariantes, servicios, catalogos y eventos.
- [ ] Documentar los limites de contexto por identidad, clientes, creditos, transferencias, pagos, auditoria y operacion.
- [ ] Explicitar que triggers protegen invariantes y procedimientos orquestan el negocio.

## 3. Modelo de dominio y relacional

- [ ] Identificar todas las entidades y su correspondencia con tablas.
- [ ] Definir cardinalidades, claves naturales, claves sustitutas y dependencias funcionales.
- [ ] Verificar campos comunes de auditoria y trazabilidad.
- [ ] Confirmar que el vocabulario del dominio coincida con SQL y SDD.

## 4. Catalogos y enums

- [ ] Listar cada catalogo requerido por el dominio bancario.
- [ ] Verificar que cada codigo usado en SQL exista en la documentacion.
- [ ] Eliminar duplicidades, ambiguedades y nombres de catalogos inconsistentes.
- [ ] Garantizar cobertura de estados intermedios y estados finales.

## 5. Validaciones e invariantes

- [ ] Verificar identificacion unica, contacto y estado de cliente.
- [ ] Validar coherencia de subtipo persona y empresa.
- [ ] Proteger saldo, estados de cuenta y ledger inmutable.
- [ ] Revisar transiciones de prestamo, transferencia, solicitud, delegacion y pago masivo.
- [ ] Revisar permisos de aprobacion por rol.
- [ ] Bloquear borrados o actualizaciones que rompan invariantes.

## 6. Servicios de dominio

- [ ] Confirmar que cada caso de uso tenga un procedimiento almacenado propio.
- [ ] Verificar que cada SP exponga contrato de entrada, salida, transaccion y bitacora.
- [ ] Revisar manejo de errores, rollback, bloqueo de filas y `trace_id`.
- [ ] Alinear la semantica de aprobacion, ejecucion, desembolso y recuperacion tecnica.

## 7. Seguridad y auditoria

- [ ] Restringir vistas por contexto real de usuario o empresa.
- [ ] Revisar permisos por rol para que reflejen el dominio y no solo el esquema tecnico.
- [ ] Definir estrategia consistente para bitacora, payload y trazabilidad.
- [ ] Aislar roles tecnicos de roles de negocio.

## 8. Desempeno y operacion

- [ ] Confirmar indices para cuentas, prestamos, transferencias, pagos y bitacora.
- [ ] Definir vencimientos y tareas programadas fuera del camino caliente.
- [ ] Revisar aislamiento transaccional y puntos de bloqueo.
- [ ] Documentar mantenimiento, respaldo y recuperacion.

## 9. Pruebas y entrega

- [ ] Definir casos de prueba por entidad, flujo y rol.
- [ ] Incluir pruebas de estados invalidos, fondos insuficientes y permisos.
- [ ] Validar secuencia de despliegue y post-migracion.
- [ ] Documentar handoff tecnico y operativo.
