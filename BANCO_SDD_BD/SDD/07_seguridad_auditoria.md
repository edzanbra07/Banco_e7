# 07. Seguridad y auditoria

## Objetivo

La seguridad debe reflejar el dominio. No basta con conceder acceso tecnico: cada rol debe ver y ejecutar solo lo que su contexto permite.

## Roles funcionales

- Cliente persona.
- Cliente empresa.
- Empleado de ventanilla.
- Empleado comercial.
- Empleado de empresa.
- Supervisor de empresa.
- Analista interno.
- Administrador tecnico.

## Matriz funcional resumida

- Cliente persona: consulta y operacion sobre sus productos propios.
- Cliente empresa: operacion sobre cartera, delegaciones y pagos de la empresa.
- Empleado de ventanilla: aperturas y operaciones de caja autorizadas.
- Empleado comercial: cartera asignada y alta de solicitudes comerciales.
- Empleado de empresa: creacion y gestion de lotes de pago masivo.
- Supervisor de empresa: aprobacion o rechazo de lotes y transferencias dentro de su ambito.
- Analista interno: aprobacion de creditos y consulta de auditoria.
- Administrador tecnico: seguridad, mantenimiento y soporte operacional.

## Lineamientos de acceso

- Los clientes solo deben consultar y operar productos propios.
- El cliente empresa solo debe operar sobre su empresa y sus permisos delegados.
- El empleado de ventanilla debe limitarse a operaciones de caja y apertura.
- El empleado comercial debe consultar cartera asignada y crear solicitudes.
- El supervisor de empresa debe aprobar o rechazar dentro de su ambito.
- El analista interno debe aprobar creditos y consultar auditoria.
- El administrador tecnico debe quedar aislado del flujo de negocio salvo tareas operativas.
- El empleado comercial debe consultar solo la cartera asignada y no todo el universo de clientes.
- El empleado de empresa debe poder crear y consultar sus lotes de pago masivo.
- El supervisor de empresa debe aprobar o ejecutar lotes segun el flujo definido.

## Vistas de lectura

- Las vistas resumen deben simplificar acceso de consulta.
- Las vistas no deben exponer toda la base sin filtro si el rol es de negocio.
- El filtro por cliente, empresa o usuario autenticado debe resolverse con el contexto de sesion o con procedimientos especializados.

## Auditoria

- `bitacora_operacion` conserva el registro de eventos significativos.
- La bitacora debe ser inmutable en el ciclo normal.
- Cada operacion critica debe registrar tipo, usuario, rol, entidad afectada, detalle, payload JSON y `trace_id`.
- La bitacora debe servir para trazabilidad operativa, analisis forense y control de cumplimiento.
- Las operaciones de solicitud de producto, delegacion y asignacion comercial deben quedar auditadas.
- Las operaciones de pago masivo deben quedar auditadas en creacion, aprobacion y ejecucion.
- Las operaciones de cuentas, prestamos y transferencias deben conservar el rastro de origen y destino cuando aplique.

## Autenticacion persistida

- `usuario_sistema` es la fuente de autenticacion del dominio bancario.
- `id_identificacion` funciona como identificador de ingreso funcional.
- `contrasena_hash` almacena la credencial cifrada y no debe exponerse en claro.
- El rol efectivo se resuelve desde `cat_rol_sistema` y debe convertirse en autoridad de sesion para API, auditoria y backend.
- La identidad autenticada debe propagarse como `id_usuario` para correlacionar auditoria y operaciones.

## Politica de trazabilidad

- El `trace_id` debe viajar desde el SP origen hasta la bitacora.
- Las vistas de auditoria deben permitir lectura por rango y por evento.
- Ninguna ruta de negocio debe perder el identificador de correlacion.

## Consideraciones de seguridad de dominio

- No conceder aprobaciones fuera del rol autorizado.
- No permitir acceso directo a tablas sensibles cuando exista un SP equivalente.
- No mezclar permisos tecnicos con permisos funcionales.
- Toda politica de acceso debe poder leerse junto con el lenguaje del dominio.

