import React from 'react';
import { IconButton } from '../core/IconButton.jsx';

export function NavHeader({ title, onBack, action, size = 'child', subtitle }) {
  const child = size === 'child';
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
      minHeight: child ? 64 : 52, padding: child ? '0 var(--gutter-pad)' : '0 var(--gutter-phone)',
    }}>
      {onBack ? <IconButton icon="chevron-left" label="返回" tone="bare" size={child ? 'parent' : 'small'} onClick={onBack} /> : null}
      <div style={{ flex: 1, minWidth: 0 }}>
        <h1 style={{ fontFamily: 'var(--font-rounded)', fontWeight: 800, fontSize: child ? 'var(--type-child-title-size)' : 'var(--type-title-size)', color: 'var(--text-strong)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</h1>
        {subtitle ? <div style={{ marginTop: 2, fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)', color: 'var(--text-muted)' }}>{subtitle}</div> : null}
      </div>
      {action}
    </div>
  );
}
