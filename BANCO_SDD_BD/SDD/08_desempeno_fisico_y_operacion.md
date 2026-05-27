# 08. Desempeno fisico y operacion

## Objetivo

Ajustar el disenio fisico para que las consultas y transacciones del dominio se mantengan estables bajo carga.

## Indices y patrones de acceso

- `cliente`: indices por identificacion, tipo y estado.
- `usuario_sistema`: indices por rol, estado, cliente y empleado.
- `cuenta`: indices por titular, estado y numero de cuenta.
- `prestamo`: indices por cliente, estado, cuenta destino y fecha de solicitud.
- `transferencia`: indices por origen, destino, estado, fechas y usuarios.
- `bitacora_operacion`: indices por fecha, usuario, tipo y trace id si se habilita.

## Escritura transaccional

- Las operaciones de saldo deben ejecutarse con bloqueo de fila.
- Las aprobaciones y desembolsos deben permanecer dentro de una unica transaccion.
- Los procedimientos de alto impacto deben minimizar el tiempo entre lectura y actualizacion.

## Operacion programada

- El vencimiento de transferencias pendientes debe resolverse con tarea programada o evento operativo.
- Las rutinas de revision tecnica deben ejecutarse fuera del camino caliente de negocio.

## Mantenimiento

- Revisar crecimiento de bitacora y movimientos.
- Validar planes de indice para consultas historicas.
- Mantener consistencia de zona horaria y modo SQL.
- Documentar procedimientos de respaldo y recuperacion.

