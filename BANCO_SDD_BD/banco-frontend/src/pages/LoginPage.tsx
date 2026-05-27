import { useMemo, useState } from 'react';
import type { FormEvent } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { Field } from '../components/ui/Field';
import { BrandMark } from '../components/ui/BrandMark';
import { useAuth } from '../context/AuthContext';
import { getApiBaseUrl } from '../lib/api';

export function LoginPage() {
  const [username, setUsername] = useState('EDZAMBRA');
  const [password, setPassword] = useState('77777777');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const destination = useMemo(() => {
    const state = location.state as { from?: { pathname?: string } } | undefined;
    return state?.from?.pathname ?? '/app';
  }, [location.state]);

  const onSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setLoading(true);
    setError(null);

    try {
      await login(username.trim(), password);
      navigate(destination, { replace: true });
    } catch (exception) {
      setError(exception instanceof Error ? exception.message : 'No fue posible autenticar');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-screen">
      <div className="auth-visual">
        <BrandMark />

        <h1>Acceso privado para operaciones financieras reales.</h1>
        <p>
          Login JWT, dashboard protegido y consumo directo contra el backend en <strong>{getApiBaseUrl()}</strong>.
        </p>

        <div className="hero-stats hero-stats--elevated">
          <article>
            <strong>JWT</strong>
            <span>Sesion privada</span>
          </article>
          <article>
            <strong>REST</strong>
            <span>Backend desacoplado</span>
          </article>
          <article>
            <strong>UX</strong>
            <span>Interfaz fintech premium</span>
          </article>
        </div>
      </div>

      <Card className="auth-card">
        <p className="eyebrow">Secure access</p>
        <h2>Entrar a Obsidian Bank</h2>
        <p className="muted">Credencial de prueba: EDZAMBRA / 77777777</p>

        <div className="login-badge-row">
          <span className="status-pill status-pill--ok">JWT activo</span>
          <span className="status-pill">CORS listo</span>
          <span className="status-pill">Swagger y APIs</span>
        </div>

        <form className="auth-form" onSubmit={onSubmit}>
          <Field label="Usuario" value={username} onChange={(event) => setUsername(event.target.value)} autoComplete="username" placeholder="EDZAMBRA" />
          <Field label="Contraseña" value={password} onChange={(event) => setPassword(event.target.value)} autoComplete="current-password" type="password" placeholder="77777777" />

          {error ? <div className="alert alert-error">{error}</div> : null}

          <Button type="submit" disabled={loading}>
            {loading ? 'Validando...' : 'Ingresar'}
          </Button>
        </form>

        <div className="login-footnote">
          <span>Acceso cifrado con BCrypt + JWT</span>
          <span>Backend: /api/auth/login</span>
        </div>
      </Card>
    </div>
  );
}