import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function TabBar({ items, active, onSelect, center }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-end', justifyContent: 'space-around', gap: 4,
      background: 'var(--surface-card)', borderTop: '1px solid var(--border-hair)',
      padding: '6px var(--space-3) 10px',
    }}>
      {items.map((it) => {
        const on = it.id === active;
        const isCenter = center && it.id === center;
        return (
          <button key={it.id} type="button" onClick={() => onSelect && onSelect(it.id)} aria-current={on ? 'page' : undefined}
            style={{
              flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
              minHeight: 'var(--touch-parent)', border: 'none', background: 'transparent', cursor: 'pointer',
              color: isCenter ? 'var(--action-accent-text)' : on ? 'var(--spruce-700)' : 'var(--text-faint)',
            }}>
            <span style={{
              display: 'grid', placeItems: 'center',
              width: isCenter ? 46 : 30, height: isCenter ? 46 : 30,
              borderRadius: isCenter ? 'var(--radius-md)' : 0,
              background: isCenter ? 'var(--action-accent)' : 'transparent',
              boxShadow: isCenter ? 'var(--shadow-card)' : 'none',
            }}><Icon name={it.icon} size={isCenter ? 26 : 24} strokeWidth={on || isCenter ? 2.4 : 2} /></span>
            <span style={{ fontFamily: 'var(--font-rounded)', fontWeight: on ? 800 : 600, fontSize: 11 }}>{it.label}</span>
          </button>
        );
      })}
    </div>
  );
}
