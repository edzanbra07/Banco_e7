type BrandMarkProps = {
  compact?: boolean;
};

export function BrandMark({ compact = false }: BrandMarkProps) {
  return (
    <div className={`brand-mark ${compact ? 'brand-mark--compact' : ''}`.trim()}>
      <span className="brand-mark__badge" aria-hidden="true">
        <span className="brand-mark__badge-core" />
      </span>
      <div>
        <strong>Obsidian Bank</strong>
        <p>Premium Digital Banking</p>
      </div>
    </div>
  );
}