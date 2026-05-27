import { useMemo } from 'react';
import { Card } from '../components/ui/Card';
import { useAuth } from '../context/AuthContext';
import { getSessionExpirationLabel } from '../lib/jwt';

const stats = [
  { label: 'Capital bajo gestion', value: '$128.4M', delta: '+12.8%' },
  { label: 'Cuentas activas', value: '18.2K', delta: '+4.6%' },
  { label: 'Transferencias hoy', value: '4,928', delta: '+9.1%' },
  { label: 'Fraude bloqueado', value: '99.8%', delta: 'SLA' }
];

const modules = [
  { title: 'Cuentas', description: 'Apertura, consulta y cambio de estado', roles: ['CLIENTE_PERSONA', 'CLIENTE_EMPRESA', 'EMPLEADO_VENTANILLA', 'ADMIN_BD'] },
  { title: 'Transferencias', description: 'Creacion, aprobacion y ejecucion', roles: ['CLIENTE_PERSONA', 'CLIENTE_EMPRESA', 'ADMIN_BD', 'SUPERVISOR_EMPRESA'] },
  { title: 'Movimientos', description: 'Historial y trazabilidad operativa', roles: [] },
  { title: 'Auditoria', description: 'Rastro y control administrativo', roles: ['ADMIN_BD'] }
];

export function DashboardPage() {
  const { session } = useAuth();

  const activeRoles = session?.roles ?? [];
  const enabledModules = useMemo(() => modules.map((module) => ({
    ...module,
    enabled: module.roles.length === 0 || module.roles.some((role) => activeRoles.includes(role))
  })), [activeRoles]);

  return (
    <>
      <Card className="hero-card">
        <div className="hero-copy">
          <p className="eyebrow">Private banking overview</p>
          <h2>Bienvenido, {session?.username}</h2>
          <p className="muted">
            Un panel oscuro, refinado y operativo para gestionar cuentas, transferencias y trazabilidad con una
            estetica fintech premium.
          </p>
        </div>

        <div className="hero-tiles">
          <article>
            <span>Usuario ID</span>
            <strong>{session?.userId ?? '-'}</strong>
          </article>
          <article>
            <span>Roles</span>
            <strong>{session?.roles.join(', ') || 'SIN_ROL'}</strong>
          </article>
          <article>
            <span>JWT</span>
            <strong>{getSessionExpirationLabel(session?.expiresAt)}</strong>
          </article>
        </div>
      </Card>

      <div className="stats-grid">
        {stats.map((stat) => (
          <Card key={stat.label} className="stat-card">
            <p className="eyebrow">{stat.label}</p>
            <strong>{stat.value}</strong>
            <span>{stat.delta}</span>
          </Card>
        ))}
      </div>

      <Card className="panel-card">
        <div className="section-heading">
          <div>
            <p className="eyebrow">Mapa de acceso</p>
            <h3>Modulos bancarios</h3>
          </div>
          <span className="status-pill status-pill--ok">Backend conectado</span>
        </div>

        <div className="module-grid">
          {enabledModules.map((module) => (
            <article key={module.title} className={`module-card ${module.enabled ? 'enabled' : 'locked'}`}>
              <div>
                <h4>{module.title}</h4>
                <p>{module.description}</p>
              </div>
              <small>{module.enabled ? 'Disponible' : 'Bloqueado por rol'}</small>
            </article>
          ))}
        </div>
      </Card>

      <div className="split-grid">
        <Card className="panel-card">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Atajos</p>
              <h3>Operaciones rapidas</h3>
            </div>
          </div>

          <div className="quick-actions">
            <div>
              <strong>Cuentas</strong>
              <span>Consulta y apertura</span>
            </div>
            <div>
              <strong>Transferencias</strong>
              <span>Flujo operativo y trazabilidad</span>
            </div>
            <div>
              <strong>Movimientos</strong>
              <span>Historial de actividad</span>
            </div>
          </div>
        </Card>

        <Card className="panel-card">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Backend</p>
              <h3>Integracion activa</h3>
            </div>
          </div>

          <table className="data-table data-table--dense">
            <thead>
              <tr>
                <th>Componente</th>
                <th>Estado</th>
                <th>Detalle</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>JWT</td>
                <td><span className="status-chip status-chip--success">Activo</span></td>
                <td>Sesion persistida en navegador</td>
              </tr>
              <tr>
                <td>CORS</td>
                <td><span className="status-chip status-chip--success">Activo</span></td>
                <td>Frontend separado habilitado</td>
              </tr>
              <tr>
                <td>Swagger</td>
                <td><span className="status-chip status-chip--success">Visible</span></td>
                <td>Documentacion lista</td>
              </tr>
              <tr>
                <td>MySQL</td>
                <td><span className="status-chip status-chip--success">Conectado</span></td>
                <td>Base local operativa</td>
              </tr>
            </tbody>
          </table>
        </Card>
      </div>
    </>
  );
}