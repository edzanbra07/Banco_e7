import { Link } from 'react-router-dom';
import { Card } from '../components/ui/Card';

export function NotFoundPage() {
  return (
    <Card className="panel-card full-width">
      <div className="empty-state">
        <h3>Ruta no encontrada</h3>
        <p>La pagina solicitada no existe dentro de la plataforma bancaria.</p>
        <Link to="/app">Volver al dashboard</Link>
      </div>
    </Card>
  );
}