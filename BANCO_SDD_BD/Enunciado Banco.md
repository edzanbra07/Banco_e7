# Actividad: Funcionamiento de la Aplicación de Gestión de Información de un Banco

## Introducción y Objetivo del Proyecto

El presente enunciado define los requisitos funcionales y de negocio para el desarrollo de un sistema de información enfocado en la gestión de clientes, productos y operaciones clave de una entidad bancaria.

El objetivo de este proyecto es que el estudiante diseñe e implemente una aplicación robusta, segura y escalable que cumpla con las normativas y flujos de trabajo descritos, infiriendo el modelo de datos (relacional y no relacional), las validaciones y los casos de uso a partir de la narrativa de negocio.

La aplicación servirá como el core transaccional y de gestión de la información fundamental del banco, permitiendo a distintos roles interactuar con los datos de clientes (personas naturales y empresas), cuentas, préstamos y transferencias, siempre bajo estrictas reglas de negocio y flujos de aprobación bien definidos.

---

## Fases del proyecto

El desarrollo se organiza en fases para facilitar la lectura del enunciado y su traducción al paquete SDD:

1. Contexto y principios de diseño
2. Modelo de dominio y contextos
3. Modelo relacional
4. Catálogos y enums
5. Validaciones y triggers
6. Procedimientos almacenados
7. Seguridad y auditoría
8. Desempeño físico y operación
9. Pruebas, migración y handoff

Estas fases se desarrollan en detalle en la carpeta [SDD](SDD/README.md).

---

# Descripción de los Roles

## Cliente Persona Natural

Corresponde a usuarios individuales del banco.

### Datos requeridos

| Campo | Descripción | Restricciones |
|--------|-------------|---------------|
| Nombre completo | Nombre y apellidos de la persona | Obligatorio |
| Número de identificación | Cédula, DNI u otro identificador nacional | Único |
| Correo electrónico | Dirección de contacto principal | Debe contener @ y dominio |
| Número de teléfono | Teléfono de contacto | 7-15 dígitos |
| Fecha de nacimiento | Fecha de nacimiento | Mayor de edad (18+) |
| Dirección | Domicilio registrado | Obligatorio |

### Visibilidad y Operaciones

- Consultar sus cuentas
- Consultar sus préstamos
- Consultar historial de transferencias propias
- Solicitar préstamos
- Realizar transferencias propias o a terceros

---

## Cliente Empresa

Representa una entidad legal cliente del banco.

### Datos requeridos

| Campo | Descripción | Restricciones |
|--------|-------------|---------------|
| Razón Social | Nombre legal de la empresa | Obligatorio |
| NIT | Identificación tributaria | Único |
| Correo electrónico | Correo corporativo | Obligatorio |
| Número de teléfono | Teléfono de contacto | 7-15 dígitos |
| Dirección | Domicilio fiscal | Obligatorio |
| Representante Legal | Referencia a Persona Natural | Obligatorio |

### Visibilidad y Operaciones

- Ver cuentas de la empresa
- Ver préstamos de la empresa
- Delegar permisos
- Aprobar transferencias de alto valor

---

## Empleado de Ventanilla

### Operaciones

- Consultar saldo/estado de cualquier cuenta
- Realizar operaciones de caja
- Apertura de nuevas cuentas

---

## Empleado Comercial

### Operaciones

- Consultar clientes asignados
- Crear solicitudes de productos
- Seguimiento a solicitudes

---

## Empleado de Empresa

### Operaciones

- Crear transferencias empresariales
- Crear pagos masivos
- Solo opera sobre su empresa

---

## Supervisor de Empresa

### Operaciones

- Aprobar/Rechazar transferencias empresariales
- Gestionar usuarios operativos

---

## Analista Interno del Banco

### Operaciones

- Aprobar/Rechazar préstamos
- Consultar bitácora completa
- Auditoría/Riesgo/Cumplimiento

---

# Información de Usuarios del Sistema

| Campo | Tipo |
|--------|------|
| ID_Usuario | Entero |
| ID_Relacionado | Texto/Numérico |
| Nombre_Completo | Texto |
| ID_Identificacion | Texto |
| Correo_Electronico | Texto |
| Telefono | Texto |
| Fecha_Nacimiento | Fecha |
| Direccion | Texto |
| Rol_Sistema | Catálogo |
| Estado_Usuario | Catálogo |

---

# Productos y Servicios Bancarios

## Cuenta Bancaria

| Campo | Tipo |
|--------|------|
| Numero_Cuenta | Texto/Numérico |
| Tipo_Cuenta | Catálogo |
| ID_Titular | Referencia Cliente |
| Saldo_Actual | Decimal |
| Moneda | Catálogo |
| Estado_Cuenta | Catálogo |
| Fecha_Apertura | Fecha |

---

## Préstamo / Crédito

| Campo | Tipo |
|--------|------|
| ID_Prestamo | Entero |
| Tipo_Prestamo | Catálogo |
| ID_Cliente_Solicitante | Referencia Cliente |
| Monto_Solicitado | Decimal |
| Monto_Aprobado | Decimal |
| Tasa_Interes | Decimal |
| Plazo_Meses | Entero |
| Estado_Prestamo | Catálogo |
| Fecha_Aprobacion | Fecha |
| Fecha_Desembolso | Fecha |
| Cuenta_Destino_Desembolso | Cuenta |

---

## Transferencia

| Campo | Tipo |
|--------|------|
| ID_Transferencia | Entero |
| Cuenta_Origen | Cuenta |
| Cuenta_Destino | Cuenta |
| Monto | Decimal |
| Fecha_Creacion | Fecha/Hora |
| Fecha_Aprobacion | Fecha/Hora |
| Estado_Transferencia | Catálogo |
| ID_Usuario_Creador | Entero |
| ID_Usuario_Aprobador | Entero |

---

## Producto Bancario General

| Campo | Tipo |
|--------|------|
| Codigo_Producto | Texto |
| Nombre_Producto | Texto |
| Categoria | Catálogo |
| Requiere_Aprobacion | Booleano |

---

# Flujos de Aprobación

## Préstamos

1. Solicitud creada
2. Estado = "En estudio"
3. Analista aprueba/rechaza
4. Si aprueba:
   - Estado = "Aprobado"
5. BackOffice desembolsa:
   - Estado = "Desembolsado"
   - Aumenta saldo cuenta destino
   - Registra bitácora

---

## Transferencias Empresariales Alto Monto

1. Empleado crea transferencia
2. Si supera umbral:
   - Estado = "En espera de aprobación"
3. Supervisor aprueba/rechaza
4. Si aprueba:
   - Validar saldo
   - Ejecutar transferencia
   - Estado = "Ejecutada"
5. Si pasa 1 hora sin aprobar:
   - Estado = "Vencida"

---

# Bitácora de Operaciones (NoSQL)

## Campos

| Campo | Tipo |
|--------|------|
| ID_Bitacora | Entero |
| Tipo_Operacion | Texto |
| Fecha_Hora_Operacion | Fecha/Hora |
| ID_Usuario | Entero |
| Rol_Usuario | Texto |
| ID_Producto_Afectado | Texto/Numérico |
| Datos_Detalle | JSON |

---

# Reglas de Negocio

## Clientes y Productos

- Identificación única global
- No abrir cuentas a usuarios inactivos/bloqueados
- Número de cuenta único
- Tipo de cuenta válido
- No operar cuentas bloqueadas/canceladas

---

## Préstamos

- Cliente solicitante debe existir y estar activo
- Solo transición:
  - En estudio → Aprobado/Rechazado
- Solo Analista Interno aprueba/rechaza
- Solo Aprobado → Desembolsado
- Desembolso requiere cuenta destino válida

---

## Transferencias

- ID único
- Monto > 0
- Validar saldo suficiente
- No usar cuentas bloqueadas/canceladas
- Transferencias pendientes >1h → Vencidas
- Ejecutar impacto financiero en cuentas

---

# Restricciones de Acceso por Rol

## Clientes

- Solo ver/operar productos propios

## Empleado Ventanilla

- Consultar cuentas
- Apertura cuentas

## Empleado Comercial

- Consultar clientes asignados
- Crear solicitudes

## Empleado Empresa

- Operar cuentas de su empresa

## Supervisor Empresa

- Aprobar transferencias empresariales

## Analista Interno

- Acceso total funcional
- No puede modificar saldos arbitrariamente

---

# Conclusiones

El desarrollo requiere:

- Modelado correcto de base relacional SQL
- Diseño de bitácora NoSQL
- Implementación de reglas de negocio
- Flujos de aprobación robustos
- Seguridad basada en roles
- Auditoría completa de operaciones