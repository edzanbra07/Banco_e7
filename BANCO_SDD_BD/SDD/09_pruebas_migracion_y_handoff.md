# 09. Pruebas, migracion y handoff

## Objetivo

Definir como validar el sistema completo antes de considerarlo entregable.

## Pruebas funcionales minimas

- Alta de cliente persona.
- Alta de cliente empresa.
- Registro de usuario sistema.
- Apertura de cuenta con saldo inicial.
- Solicitud, aprobacion, rechazo y desembolso de prestamo.
- Creacion, aprobacion, rechazo, ejecucion y vencimiento de transferencia.
- Creacion y consulta de solicitudes de producto.
- Creacion y consulta de delegaciones.
- Creacion y consulta de asignaciones comerciales.
- Creacion, aprobacion, rechazo y ejecucion de pagos masivos.
- Registro y consulta de bitacora.

## Pruebas negativas

- Cliente menor de edad.
- Empresa sin representante valido.
- Cuenta con saldo negativo.
- Prestamo con cliente inactivo.
- Transferencia sin saldo suficiente.
- Aprobacion por rol no autorizado.
- Modificacion de bitacora.
- Consulta de cartera no asignada por un comercial.
- Ejecucion de pago masivo sin aprobacion previa.

## Orden de migracion

1. Crear esquema y modo de sesion.
2. Crear catalogos.
3. Crear tablas.
4. Crear indices adicionales.
5. Crear triggers.
6. Crear procedimientos.
7. Crear vistas y roles.
8. Cargar datos semilla y validar recorridos.

## Criterios de aceptacion

- Todas las entidades del enunciado deben tener representacion explicita.
- Todas las reglas del dominio deben tener al menos una barrera de integridad.
- Todos los flujos significativos deben poder ejecutarse sin SQL manual de soporte.
- Todo rol funcional debe tener una politica clara de lectura y escritura.

## Handoff

- Entregar diccionario de entidades y catalogos.
- Entregar orden de ejecucion de scripts.
- Entregar casos de prueba y datos de ejemplo.
- Entregar decisiones pendientes o riesgos conocidos.

