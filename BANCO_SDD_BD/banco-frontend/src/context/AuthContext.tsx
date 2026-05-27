import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';
import type { AuthSession } from '../types';
import { decodeJwtPayload } from '../lib/jwt';
import { clearSession, readSession, writeSession } from '../lib/storage';
import { loginRequest } from '../lib/api';

interface AuthContextValue {
  session: AuthSession | null;
  isAuthenticated: boolean;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  hasRole: (role: string) => boolean;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<AuthSession | null>(null);

  useEffect(() => {
    setSession(readSession());
  }, []);

  const login = async (username: string, password: string) => {
    const response = await loginRequest(username, password);
    const payload = decodeJwtPayload(response.token);

    const nextSession: AuthSession = {
      token: response.token,
      tokenType: response.tokenType,
      username: response.username,
      roles: response.roles,
      userId: payload?.userId ?? 0,
      expiresAt: payload?.exp
    };

    writeSession(nextSession);
    setSession(nextSession);
  };

  const logout = () => {
    clearSession();
    setSession(null);
  };

  const hasRole = (role: string) => session?.roles.includes(role) ?? false;

  const value = useMemo<AuthContextValue>(() => ({
    session,
    isAuthenticated: Boolean(session),
    login,
    logout,
    hasRole
  }), [session]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}