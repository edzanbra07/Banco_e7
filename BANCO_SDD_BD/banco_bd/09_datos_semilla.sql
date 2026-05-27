USE banco_bd;

START TRANSACTION;

SET @hash_admin = '$2a$10$0e2WkbM1V5LwQGnOUgcd3O.tRAyOxw0UDkIgrEs9XbvwQMCY5P8yG';
SET @hash_cliente = '$2a$10$0e2WkbM1V5LwQGnOUgcd3O.tRAyOxw0UDkIgrEs9XbvwQMCY5P8yG';
SET @hash_comercial = '$2a$10$0e2WkbM1V5LwQGnOUgcd3O.tRAyOxw0UDkIgrEs9XbvwQMCY5P8yG';
SET @hash_edzambra = '$2a$10$sj6cJItn8i9bYBvPRwg3uewiRYtyTGJ/hG/19uK0R4td3IEDHI82e';

INSERT INTO empleado (
  tipo_empleado_id,
  estado_empleado_id,
  id_identificacion,
  nombres,
  apellidos,
  cargo,
  area,
  correo_interno,
  telefono,
  created_by,
  updated_by
)
VALUES (
  (SELECT id_catalogo FROM cat_tipo_empleado WHERE codigo = 'COMERCIAL' LIMIT 1),
  (SELECT id_catalogo FROM cat_estado_empleado WHERE codigo = 'ACTIVO' LIMIT 1),
  'EMP-10001',
  'Laura',
  'Mendez',
  'Ejecutiva Comercial',
  'Banca Personas',
  'laura.mendez@banco.local',
  '70010001',
  NULL,
  NULL
);
SET @empleado_comercial_id = LAST_INSERT_ID();

INSERT INTO usuario_sistema (
  id_empleado,
  rol_sistema_id,
  estado_usuario_id,
  nombre_completo,
  id_identificacion,
  contrasena_hash,
  correo_electronico,
  telefono,
  fecha_nacimiento,
  direccion,
  created_by,
  updated_by
)
VALUES (
  @empleado_comercial_id,
  (SELECT id_catalogo FROM cat_rol_sistema WHERE codigo = 'EMPLEADO_COMERCIAL' LIMIT 1),
  (SELECT id_catalogo FROM cat_estado_usuario WHERE codigo = 'ACTIVO' LIMIT 1),
  'Laura Mendez',
  'EMP-10001',
  @hash_comercial,
  'laura.mendez@banco.local',
  '70010001',
  '1990-04-12',
  'Av. Central 100',
  NULL,
  NULL
);

INSERT INTO empleado (
  tipo_empleado_id,
  estado_empleado_id,
  id_identificacion,
  nombres,
  apellidos,
  cargo,
  area,
  correo_interno,
  telefono,
  created_by,
  updated_by
)
VALUES (
  (SELECT id_catalogo FROM cat_tipo_empleado WHERE codigo = 'ANALISTA' LIMIT 1),
  (SELECT id_catalogo FROM cat_estado_empleado WHERE codigo = 'ACTIVO' LIMIT 1),
  'EMP-10002',
  'Andrea',
  'Torres',
  'Administradora de Base de Datos',
  'Tecnologia',
  'andrea.torres@banco.local',
  '70010002',
  NULL,
  NULL
);
SET @empleado_admin_id = LAST_INSERT_ID();

INSERT INTO usuario_sistema (
  id_empleado,
  rol_sistema_id,
  estado_usuario_id,
  nombre_completo,
  id_identificacion,
  contrasena_hash,
  correo_electronico,
  telefono,
  fecha_nacimiento,
  direccion,
  created_by,
  updated_by
)
VALUES (
  @empleado_admin_id,
  (SELECT id_catalogo FROM cat_rol_sistema WHERE codigo = 'ADMIN_BD' LIMIT 1),
  (SELECT id_catalogo FROM cat_estado_usuario WHERE codigo = 'ACTIVO' LIMIT 1),
  'Andrea Torres',
  'EMP-10002',
  @hash_admin,
  'andrea.torres@banco.local',
  '70010002',
  '1987-11-03',
  'Av. Tecnologia 200',
  NULL,
  NULL
);

INSERT INTO empleado (
  tipo_empleado_id,
  estado_empleado_id,
  id_identificacion,
  nombres,
  apellidos,
  cargo,
  area,
  correo_interno,
  telefono,
  created_by,
  updated_by
)
VALUES (
  (SELECT id_catalogo FROM cat_tipo_empleado WHERE codigo = 'COMERCIAL' LIMIT 1),
  (SELECT id_catalogo FROM cat_estado_empleado WHERE codigo = 'ACTIVO' LIMIT 1),
  'EDZAMBRA',
  'Edzambra',
  'Demo',
  'Ejecutivo Comercial',
  'Canales Digitales',
  'edzambra@banco.local',
  '70019999',
  NULL,
  NULL
);
SET @empleado_edzambra_id = LAST_INSERT_ID();

INSERT INTO usuario_sistema (
  id_empleado,
  rol_sistema_id,
  estado_usuario_id,
  nombre_completo,
  id_identificacion,
  contrasena_hash,
  correo_electronico,
  telefono,
  fecha_nacimiento,
  direccion,
  created_by,
  updated_by
)
VALUES (
  @empleado_edzambra_id,
  (SELECT id_catalogo FROM cat_rol_sistema WHERE codigo = 'EMPLEADO_COMERCIAL' LIMIT 1),
  (SELECT id_catalogo FROM cat_estado_usuario WHERE codigo = 'ACTIVO' LIMIT 1),
  'Edzambra Demo',
  'EDZAMBRA',
  @hash_edzambra,
  'edzambra@banco.local',
  '70019999',
  '1992-06-15',
  'Av. Test 123',
  NULL,
  NULL
);

INSERT INTO cliente (
  tipo_cliente_id,
  estado_cliente_id,
  id_identificacion,
  nombre_completo,
  correo_electronico,
  telefono,
  direccion,
  created_by,
  updated_by
)
VALUES (
  (SELECT id_catalogo FROM cat_tipo_cliente WHERE codigo = 'PERSONA' LIMIT 1),
  (SELECT id_catalogo FROM cat_estado_cliente WHERE codigo = 'ACTIVO' LIMIT 1),
  'CLI-20001',
  'Juan Perez Gomez',
  'juan.perez@example.com',
  '70120001',
  'Calle 5 # 10-20',
  NULL,
  NULL
);
SET @cliente_persona_id = LAST_INSERT_ID();

INSERT INTO cliente_persona (
  id_cliente,
  nombres,
  apellidos,
  fecha_nacimiento,
  created_by,
  updated_by
)
VALUES (
  @cliente_persona_id,
  'Juan',
  'Perez Gomez',
  '1988-09-21',
  NULL,
  NULL
);

INSERT INTO usuario_sistema (
  id_cliente,
  rol_sistema_id,
  estado_usuario_id,
  nombre_completo,
  id_identificacion,
  contrasena_hash,
  correo_electronico,
  telefono,
  fecha_nacimiento,
  direccion,
  created_by,
  updated_by
)
VALUES (
  @cliente_persona_id,
  (SELECT id_catalogo FROM cat_rol_sistema WHERE codigo = 'CLIENTE_PERSONA' LIMIT 1),
  (SELECT id_catalogo FROM cat_estado_usuario WHERE codigo = 'ACTIVO' LIMIT 1),
  'Juan Perez Gomez',
  'CLI-20001',
  @hash_cliente,
  'juan.perez@example.com',
  '70120001',
  '1988-09-21',
  'Calle 5 # 10-20',
  NULL,
  NULL
);

INSERT INTO cuenta (
  numero_cuenta,
  id_titular_cliente,
  tipo_cuenta_id,
  moneda_id,
  estado_cuenta_id,
  saldo_actual,
  fecha_apertura,
  created_by,
  updated_by
)
VALUES (
  '1000000001',
  @cliente_persona_id,
  (SELECT id_catalogo FROM cat_tipo_cuenta WHERE codigo = 'AHORRO' LIMIT 1),
  (SELECT id_catalogo FROM cat_moneda WHERE codigo = 'BOB' LIMIT 1),
  (SELECT id_catalogo FROM cat_estado_cuenta WHERE codigo = 'ACTIVA' LIMIT 1),
  2500.00,
  CURDATE(),
  NULL,
  NULL
);

INSERT INTO cliente_asignacion_comercial (
  id_cliente,
  id_empleado_comercial,
  fecha_inicio,
  fecha_fin,
  observacion,
  created_by,
  updated_by
)
VALUES (
  @cliente_persona_id,
  @empleado_comercial_id,
  CURDATE(),
  NULL,
  'Asignacion comercial de ejemplo',
  NULL,
  NULL
);

COMMIT;