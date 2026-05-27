import { useEffect, useState } from 'react';
import { Card } from '../components/ui/Card';
import { useAuth } from '../context/AuthContext';
import { getTransfersByUserId } from '../lib/api';
import type { TransferenciaResumen } from '../types';

export function MovementsPage() {
  const { session } = useAuth();
  const [items, setItems] = useState<TransferenciaResumen[]>([]);
  const [loading, setLoading] = useState(false);
  const [status, setStatus] = useState<string | null>(null);

  useEffect(() => {
    let active = true;

    const load = async () => {
      if (!session) {
        return;
      }

      setLoading(true);
      setStatus(null);

      try {
        const response = await getTransfersByUserId(session.token, session.userId);
        if (active) {
          setItems(response.transferencias ?? []);
        }
      } catch (exception) {
        if (active) {
          setStatus(exception instanceof Error ? exception.message : 'No fue posible consultar los movimientos');
        }
      } finally {
        if (active) {
          setLoading(false);
        }
      }
    };

    void load();

    return () => {
      active = false;
    };
  }, [session]);

  return (
    <Card className="panel-card full-width">
      <div className="section-heading">
        <div>
          <p className="eyebrow">Movimientos</p>
          <h3>Trazabilidad operativa</h3>
        </div>
      </div>

      {loading ? <div className="empty-state">Cargando movimientos...</div> : null}
      {status ? <div className="alert alert-error">{status}</div> : null}

      {!loading && !status && items.length === 0 ? (
        <div className="empty-state">
          <h4>Sin movimientos visibles</h4>
          <p>El backend esta listo; cuando este usuario tenga transferencias, apareceran aqui con su trazabilidad.</p>
        </div>
      ) : null}

      <div className="timeline">
        {items.map((item) => (
          <article key={item.idTransferencia} className="timeline-item">
            <div>
              <strong>Transferencia #{item.idTransferencia}</strong>
              <p>
                Origen {item.cuentaOrigenId} → Destino {item.cuentaDestinoId}
              </p>
            </div>
            <div>
              <strong>{item.monto}</strong>
              <p>{item.estadoTransferenciaCodigo}</p>
            </div>
          </article>
        ))}
      </div>
    </Card>
  );
}