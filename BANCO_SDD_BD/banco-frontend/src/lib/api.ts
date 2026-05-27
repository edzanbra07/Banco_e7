import type {
  ApiResponse,
  AuthResponse,
  CuentaAbrirRequest,
  CuentaConsultaResponse,
  TransferenciaCrearRequest,
  TransferenciaDecisionRequest,
  TransferenciaHistorialResponse,
  TransferenciaOperacionResponse
} from '../types';

const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8083').replace(/\/$/, '');

export class ApiError extends Error {
  status: number;
  responseBody: unknown;

  constructor(message: string, status: number, responseBody: unknown) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.responseBody = responseBody;
  }
}

async function parseJsonResponse<T>(response: Response): Promise<T> {
  const text = await response.text();
  if (!text) {
    return undefined as T;
  }

  try {
    return JSON.parse(text) as T;
  } catch {
    return text as T;
  }
}

export async function apiRequest<T>(path: string, init: RequestInit = {}, token?: string): Promise<T> {
  const headers = new Headers(init.headers ?? {});
  headers.set('Accept', 'application/json');

  if (init.body && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json');
  }

  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...init,
    headers
  });

  const payload = await parseJsonResponse<ApiResponse<T> | { message?: string } | T>(response);

  if (!response.ok) {
    const message = typeof payload === 'object' && payload && 'message' in payload && typeof payload.message === 'string'
      ? payload.message
      : `HTTP ${response.status}`;
    throw new ApiError(message, response.status, payload);
  }

  if (typeof payload === 'object' && payload && 'data' in payload) {
    return (payload as ApiResponse<T>).data;
  }

  return payload as T;
}

export function getApiBaseUrl(): string {
  return API_BASE_URL;
}

export async function loginRequest(username: string, password: string): Promise<AuthResponse> {
  return apiRequest<AuthResponse>('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ username, password })
  });
}

export async function getAccountsByUserId(token: string, userId: number): Promise<CuentaConsultaResponse> {
  return apiRequest<CuentaConsultaResponse>(`/api/cuentas/usuarios/${userId}`, {}, token);
}

export async function openAccount(token: string, request: CuentaAbrirRequest): Promise<unknown> {
  return apiRequest<unknown>('/api/cuentas', {
    method: 'POST',
    body: JSON.stringify(request)
  }, token);
}

export async function getTransfersByUserId(token: string, userId: number): Promise<TransferenciaHistorialResponse> {
  return apiRequest<TransferenciaHistorialResponse>(`/api/transferencias/usuarios/${userId}`, {}, token);
}

export async function createTransfer(token: string, request: TransferenciaCrearRequest): Promise<TransferenciaOperacionResponse> {
  return apiRequest<TransferenciaOperacionResponse>('/api/transferencias', {
    method: 'POST',
    body: JSON.stringify(request)
  }, token);
}

export async function decideTransfer(
  token: string,
  idTransferencia: number,
  action: 'aprobar' | 'rechazar',
  request: TransferenciaDecisionRequest
): Promise<TransferenciaOperacionResponse> {
  return apiRequest<TransferenciaOperacionResponse>(`/api/transferencias/${idTransferencia}/${action}`, {
    method: 'POST',
    body: JSON.stringify(request)
  }, token);
}