import type { FormEvent } from 'react';
import { useState } from 'react';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { Field } from '../components/ui/Field';
import { useAuth } from '../context/AuthContext';
import { createTransfer } from '../lib/api';
import type { TransferenciaCrearRequest } from '../types';

const initialForm: TransferenciaCrearRequest = {
  cuentaOrigenId: 0,
  cuentaDestinoId: 0,
  monto: '0.00'
};

const allowedRoles = ['CLIENTE_PERSONA', 'CLIENTE_EMPRESA', 'ADMIN_BD'];

export function TransfersPage() {
  const { session, hasRole } = useAuth();
  const isAllowed = allowedRoles.some((role) => hasRole(role));
  const [form, setForm] = useState<TransferenciaCrearRequest>(initialForm);
  const [status, setStatus] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const updateField = <K extends keyof TransferenciaCrearRequest>(key: K, value: TransferenciaCrearRequest[K]) => {
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
      const result = await createTransfer(session.token, form);
      setStatus(`Transferencia creada: ${result.idTransferencia} | Trace ${result.traceId}`);
    } catch (exception) {
      setStatus(exception instanceof Error ? exception.message : 'No fue posible crear la transferencia');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="panel-card full-width">
      <div className="section-heading">
        <div>
          <p className="eyebrow">Transferencias</p>
          <h3>Creacion y flujo operativo</h3>
        </div>
        <span className={`status-pill ${isAllowed ? 'status-pill--ok' : 'status-pill--warn'}`}>
          {isAllowed ? 'Operativa habilitada' : 'Solo lectura para este rol'}
        </span>
      </div>

      {isAllowed ? (
        <form className="stack-form" onSubmit={onSubmit}>
          <div className="mini-copy">
            <strong>Transferencias seguras</strong>
            <span>Interfaz oscura, minimalista y pensada para operar sin friccion.</span>
          </div>
          <div className="form-grid">
            <Field label="Cuenta origen" type="number" value={form.cuentaOrigenId} onChange={(event) => updateField('cuentaOrigenId', Number(event.target.value))} />
            <Field label="Cuenta destino" type="number" value={form.cuentaDestinoId} onChange={(event) => updateField('cuentaDestinoId', Number(event.target.value))} />
            <Field label="Monto" type="number" step="0.01" value={form.monto} onChange={(event) => updateField('monto', event.target.value)} />
          </div>

          {status ? <div className="alert">{status}</div> : null}

          <Button type="submit" disabled={loading}>
            {loading ? 'Procesando...' : 'Crear transferencia'}
          </Button>
        </form>
      ) : (
        <div className="empty-state">
          <h4>Modulo bloqueado por rol</h4>
          <p>
            La creacion de transferencias esta disponible para clientes o administradores, manteniendo la separacion
            con el backend ya autenticado por JWT.
          </p>
        </div>
      )}
    </Card>
  );
}