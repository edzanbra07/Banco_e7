import type { FormEvent } from 'react';
import { useState } from 'react';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { Field } from '../components/ui/Field';
import { useAuth } from '../context/AuthContext';
import { openAccount } from '../lib/api';
import type { CuentaAbrirRequest } from '../types';

const initialForm: CuentaAbrirRequest = {
  idTitularCliente: 0,
  numeroCuenta: '',
  tipoCuentaCodigo: 'AHORRO',
  monedaCodigo: 'BOB',
  saldoInicial: '0.00'
};

const allowedRoles = ['EMPLEADO_VENTANILLA', 'ADMIN_BD'];

export function AccountsPage() {
  const { session, hasRole } = useAuth();
  const isAllowed = allowedRoles.some((role) => hasRole(role));
  const [form, setForm] = useState<CuentaAbrirRequest>(initialForm);
  const [status, setStatus] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const updateField = <K extends keyof CuentaAbrirRequest>(key: K, value: CuentaAbrirRequest[K]) => {
    setForm((current) => ({ ...current, [key]: value }));
  };

  const onSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!session) {
      return;
    }

    setLoading(true);
    setStatus(null);

    try {
      await openAccount(session.token, form);
      setStatus('Cuenta enviada correctamente al backend.');
    } catch (exception) {
      setStatus(exception instanceof Error ? exception.message : 'No fue posible abrir la cuenta');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="panel-card full-width">
      <div className="section-heading">
        <div>
          <p className="eyebrow">Cuentas</p>
          <h3>Apertura y control</h3>
        </div>
        <span className={`status-pill ${isAllowed ? 'status-pill--ok' : 'status-pill--warn'}`}>
          {isAllowed ? 'Operativa habilitada' : 'Solo lectura para este rol'}
        </span>
      </div>

      {isAllowed ? (
        <form className="stack-form" onSubmit={onSubmit}>
          <div className="mini-copy">
            <strong>Diseño operativo</strong>
            <span>La forma sigue la logica del backend; la experiencia es mas limpia y premium.</span>
          </div>
          <div className="form-grid">
            <Field label="ID titular cliente" type="number" value={form.idTitularCliente} onChange={(event) => updateField('idTitularCliente', Number(event.target.value))} />
            <Field label="Numero de cuenta" value={form.numeroCuenta} onChange={(event) => updateField('numeroCuenta', event.target.value)} />
            <Field label="Tipo de cuenta" value={form.tipoCuentaCodigo} onChange={(event) => updateField('tipoCuentaCodigo', event.target.value)} />
            <Field label="Moneda" value={form.monedaCodigo} onChange={(event) => updateField('monedaCodigo', event.target.value)} />
            <Field label="Saldo inicial" type="number" step="0.01" value={form.saldoInicial} onChange={(event) => updateField('saldoInicial', event.target.value)} />
          </div>

          {status ? <div className="alert">{status}</div> : null}

          <Button type="submit" disabled={loading}>
            {loading ? 'Procesando...' : 'Abrir cuenta'}
          </Button>
        </form>
      ) : (
        <div className="empty-state">
          <h4>Modulo bloqueado por rol</h4>
          <p>
            Este usuario puede entrar al banco y ver el dashboard, pero la apertura de cuentas solo aplica a
            <strong> EMPLEADO_VENTANILLA </strong>o <strong>ADMIN_BD</strong>.
          </p>
        </div>
      )}
    </Card>
  );
}