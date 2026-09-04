import React from 'react';

export function Toggle({ checked, onChange, label, hint, disabled }) {
  return (
    <label style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)', minHeight: 'var(--touch-parent)', cursor: disabled ? 'default' : 'pointer' }}>
      <span style={{ flex: 1 }}>
        <span style={{ display: 'block', fontFamily: 'var(--font-text)', fontWeight: 600, fontSize: 'var(--type-body-size)', color: 'var(--text-strong)' }}>{label}</span>
        {hint ? <span style={{ display: 'block', marginTop: 2, fontSize: 'var(--type-caption-size)', color: 'var(--text-muted)' }}>{hint}</span> : null}
      </span>
      <button type="button" role="switch" aria-checked={!!checked} aria-label={label} disabled={disabled}
        onClick={() => onChange && onChange(!checked)}
        style={{
          width: 52, height: 32, flex: '0 0 auto', borderRadius: 'var(--radius-pill)', border: 'none',
          background: disabled ? 'var(--disabled-bg)' : checked ? 'var(--leaf-500)' : 'var(--paper-300)',
          padding: 3, cursor: disabled ? 'default' : 'pointer',
          transition: 'background var(--dur-fast) var(--ease-standard)',
        }}>
        <span style={{
          display: 'block', width: 26, height: 26, borderRadius: '50%', background: 'var(--paper-000)',
          boxShadow: '0 1px 3px rgba(14,42,36,.28)',
          transform: `translateX(${checked ? 20 : 0}px)`,
          transition: 'transform var(--dur-fast) var(--ease-bounce)',
        }} />
      </button>
    </label>
  );
}
