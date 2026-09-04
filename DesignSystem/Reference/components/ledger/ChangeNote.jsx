import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function ChangeNote({ text, date, size = 'child' }) {
  const child = size === 'child';
  return (
    <div style={{
      display: 'flex', gap: 12, alignItems: 'flex-start',
      background: 'var(--surface-sunken)', borderRadius: 'var(--radius-lg)',
      padding: child ? 'var(--space-5)' : 'var(--space-4)',
    }}>
      <Icon name="pencil-line" size={child ? 22 : 18} color="var(--money-fix)" style={{ marginTop: 2 }} />
      <div>
        <div style={{ fontFamily: 'var(--font-text)', fontWeight: 600, fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)', color: 'var(--text-strong)' }}>{text}</div>
        {date ? <div style={{ marginTop: 4, fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)', color: 'var(--text-muted)' }}>{date}</div> : null}
      </div>
    </div>
  );
}
