export interface ApiResponse<T> {
  success: boolean;
  message: string;
  path: string;
  timestamp: string;
  data: T;
}

export interface AuthResponse {
  token: string;
  tokenType: string;
  username: string;
  roles: string[];
}

export interface JwtPayload {
  sub?: string;
  userId?: number;
  roles?: string[];
  iat?: number;
  exp?: number;
}

export interface AuthSession {
  token: string;
  tokenType: string;
  username: string;
  roles: string[];
  userId: number;
  expiresAt?: number;
}

export interface CuentaResumen {
  idCuenta: number;
  numeroCuenta: string;
  saldoActual: string;
  fechaApertura: string;
  estadoCuentaCodigo: string;
  tipoCuentaCodigo: string;
  monedaCodigo: string;
}

export interface CuentaConsultaResponse {
  idUsuario: number;
  traceId: string;
  cuentas: CuentaResumen[];
}

export interface TransferenciaResumen {
  idTransferencia: number;
  cuentaOrigenId: number;
  cuentaDestinoId: number;
  monto: string;
  estadoTransferenciaCodigo: string;
  fechaCreacion: string;
  fechaAprobacion: string | null;
  fechaEjecucion: string | null;
  fechaVencimiento: string | null;
  idUsuarioCreador: number;
  idUsuarioAprobador: number | null;
  observacion: string | null;
}

export interface TransferenciaHistorialResponse {
  idUsuario: number;
  traceId: string;
  transferencias: TransferenciaResumen[];
}

export interface TransferenciaOperacionResponse {
  idTransferencia: number;
  traceId: string;
}

export interface CuentaAbrirRequest {
  idTitularCliente: number;
  numeroCuenta: string;
  tipoCuentaCodigo: string;
  monedaCodigo: string;
  saldoInicial: string;
}

export interface TransferenciaCrearRequest {
  cuentaOrigenId: number;
  cuentaDestinoId: number;
  monto: string;
}

export interface TransferenciaDecisionRequest {
  observacion?: string;
}