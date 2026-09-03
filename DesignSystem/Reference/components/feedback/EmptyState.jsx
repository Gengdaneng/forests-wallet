import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function EmptyState({ icon = 'notebook-pen', title, body, size = 'child' }) {
  const child = size === 'child';
  return (
    <div style={{ textAlign: 'center', padding: child ? 'var(--space-10) var(--space-7)' : 'var(--space-8) var(--space-5)' }}>
      <div style={{ display: 'grid', placeItems: 'center', width: child ? 88 : 64, height: child ? 88 : 64, margin: '0 auto var(--space-5)', borderRadius: 'var(--radius-xl)', background: 'var(--surface-leaf)', color: 'var(--spruce-600)' }}>
        <Icon name={icon} size={child ? 40 : 30} />
      </div>
      <div style={{ fontFamily: 'var(--font-rounded)', fontWeight: 800, fontSize: child ? 'var(--type-child-head-size)' : 'var(--type-head-size)', color: 'var(--text-strong)' }}>{title}</div>
      {body ? <div style={{ maxWidth: 420, margin: 'var(--space-3) auto 0', fontFamily: 'var(--font-text)', fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)', color: 'var(--text-muted)' }}>{body}</div> : null}
    </div>
  );
}
