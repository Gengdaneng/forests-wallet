import React from 'react';
import { Icon } from '../core/Icon.jsx';
import { Badge } from '../core/Badge.jsx';

export function RuleRow({ name, detail, rewardCents, met, size = 'child', kind = 'base', onClick }) {
  const child = size === 'child';
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: child ? 'var(--space-5)' : 'var(--space-4)',
      minHeight: child ? 'var(--touch-child)' : 'var(--touch-parent)',
      padding: child ? 'var(--space-4) 0' : 'var(--space-3) 0',
      borderBottom: '1px solid var(--border-hair)', cursor: onClick ? 'pointer' : undefined,
    }}>
      <div style={{ display: 'grid', placeItems: 'center', width: child ? 44 : 36, height: child ? 44 : 36, borderRadius: 'var(--radius-md)', background: kind === 'base' ? 'var(--surface-leaf)' : 'var(--surface-honey)', color: kind === 'base' ? 'var(--spruce-700)' : 'var(--honey-700)', flex: '0 0 auto' }}>
        <Icon name={kind === 'base' ? 'repeat' : 'sparkles'} size={child ? 22 : 18} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: 'var(--font-rounded)', fontWeight: 700, fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)', color: 'var(--text-strong)' }}>{name}</div>
        {detail ? <div style={{ marginTop: 2, fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)', color: 'var(--text-muted)' }}>{detail}</div> : null}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, flex: '0 0 auto' }}>
        {met !== undefined ? <Badge tone={met ? 'in' : 'neutral'} icon={met ? 'check' : 'clock'} size={size}>{met ? '做到了' : '还没记'}</Badge> : null}
        <span style={{ fontFamily: 'var(--font-rounded)', fontWeight: 800, fontVariantNumeric: 'tabular-nums', fontSize: child ? 'var(--type-amount-size)' : 'var(--type-amount-sm-size)', color: 'var(--spruce-700)' }}>¥{Math.round(rewardCents / 100)}</span>
      </div>
    </div>
  );
}
