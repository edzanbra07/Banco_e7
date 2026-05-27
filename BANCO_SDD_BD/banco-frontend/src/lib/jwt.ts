import type { JwtPayload } from '../types';

function base64UrlToBase64(value: string): string {
  const normalized = value.replace(/-/g, '+').replace(/_/g, '/');
  const padding = normalized.length % 4;
  return padding === 0 ? normalized : normalized + '='.repeat(4 - padding);
}

export function decodeJwtPayload(token: string): JwtPayload | null {
  try {
    const payload = token.split('.')[1];
    if (!payload) {
      return null;
    }

    const json = atob(base64UrlToBase64(payload));
    return JSON.parse(json) as JwtPayload;
  } catch {
    return null;
  }
}

export function getSessionExpirationLabel(expiresAt?: number): string {
  if (!expiresAt) {
    return 'Sin expiracion visible';
  }

  const remainingMs = expiresAt * 1000 - Date.now();
  if (remainingMs <= 0) {
    return 'Expirada';
  }

  const remainingMinutes = Math.max(1, Math.round(remainingMs / 60000));
  return `${remainingMinutes} min restantes`;
}