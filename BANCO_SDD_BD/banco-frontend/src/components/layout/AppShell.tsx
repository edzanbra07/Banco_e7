import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { Button } from '../ui/Button';
import { BrandMark } from '../ui/BrandMark';
import { getSessionExpirationLabel } from '../../lib/jwt';

const navigation = [
  { to: '/app', label: 'Dashboard', roles: [] },
  { to: '/app/cuentas', label: 'Cuentas', roles: ['CLIENTE_PERSONA', 'CLIENTE_EMPRESA', 'EMPLEADO_VENTANILLA', 'ADMIN_BD'] },
  { to: '/app/transferencias', label: 'Transferencias', roles: ['CLIENTE_PERSONA', 'CLIENTE_EMPRESA', 'ADMIN_BD', 'SUPERVISOR_EMPRESA'] },
  { to: '/app/movimientos', label: 'Movimientos', roles: [] }
];

export function AppShell() {
  const { session, logout } = useAuth();
  const roleLabel = session?.roles[0] ?? 'SIN ROL';

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <BrandMark />

        <div className="sidebar-hero">
          <p className="eyebrow">Session control</p>
          <strong>Seguridad, trazabilidad y operaciones</strong>
          <span>JWT activo, backend desacoplado y UI premium responsive.</span>
        </div>

        <nav className="sidebar-nav">
          {navigation.map((item) => (
            <NavLink key={item.to} to={item.to} end={item.to === '/app'} className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
              <span>{item.label}</span>
              {item.roles.length > 0 ? <small>{item.roles.includes(roleLabel) ? 'Acceso' : 'Bloqueado'}</small> : null}
            </NavLink>
          ))}
        </nav>

        <div className="sidebar-panel">
          <p className="eyebrow">Sesion JWT</p>
          <strong>{session?.username}</strong>
          <span>{roleLabel}</span>
          <small>{getSessionExpirationLabel(session?.expiresAt)}</small>
          <Button variant="ghost" onClick={logout}>Cerrar sesion</Button>
        </div>
      </aside>

      <div className="app-main">
        <header className="topbar">
          <div>
            <p className="eyebrow">Obsidian Bank</p>
            <h1>Premium fintech control center</h1>
          </div>
          <div className="topbar-actions">
            <span className="role-chip">{roleLabel}</span>
            <Button variant="ghost" onClick={logout}>Salir</Button>
          </div>
        </header>

        <main className="content-grid">
          <Outlet />
        </main>
      </div>
    </div>
  );
}