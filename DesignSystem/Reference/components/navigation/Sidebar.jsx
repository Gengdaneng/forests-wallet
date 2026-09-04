import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function Sidebar({ items, active, onSelect, brand = "Forrest's Wallet", footer }) {
  return (
    <nav style={{
      width: 'var(--sidebar-pad-width)', flex: '0 0 auto', display: 'flex', flexDirection: 'column',
      background: 'var(--surface-ink)', color: 'var(--text-on-ink)',
      padding: 'var(--space-8) var(--space-5)', gap: 'var(--space-7)',
    }}>
      {/* No logo mark exists in the source repo — the wordmark is set in type. */}
      <div style={{ fontFamily: 'var(--font-rounded)', fontWeight: 900, fontSize: 22, letterSpacing: 'var(--tracking-tight)', color: 'var(--honey-500)', padding: '0 var(--space-3)' }}>{brand}</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-2)' }}>
        {items.map((it) => {
          const on = it.id === active;
          return (
            <button key={it.id} type="button" onClick={() => onSelect && onSelect(it.id)}
              style={{
                display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
                minHeight: 'var(--touch-child)', padding: '0 var(--space-4)',
                borderRadius: 'var(--radius-lg)', border: 'none', textAlign: 'left',
                background: on ? 'rgba(251,247,237,.14)' : 'transparent',
                color: on ? 'var(--paper-000)' : 'var(--text-on-ink-muted)',
                fontFamily: 'var(--font-rounded)', fontWeight: on ? 800 : 600,
                fontSize: 'var(--type-child-label-size)', cursor: 'pointer',
                transition: 'background var(--dur-fast) var(--ease-standard)',
              }}>
              <Icon name={it.icon} size={24} />{it.label}
            </button>
          );
        })}
      </div>
      <div style={{ marginTop: 'auto' }}>{footer}</div>
    </nav>
  );
}
