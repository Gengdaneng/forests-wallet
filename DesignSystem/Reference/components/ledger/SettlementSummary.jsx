import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function SettlementSummary({ lines, bonus, size = 'parent' }) {
  const child = size === 'child';
  const total = lines.reduce((s, l) => s + (l.met ? l.rewardCents : 0), 0) + (bonus && bonus.met ? bonus.rewardCents : 0);
  const fs = child ? 'var(--type-child-body-size)' : 'var(--type-body-size)';
  const row = (label, note, cents, met, key) => (
    <div key={key} style={{ display: 'flex', alignItems: 'baseline', gap: 10, padding: child ? '10px 0' : '7px 0' }}>
      <span style={{ fontFamily: 'var(--font-text)', fontWeight: 600, fontSize: fs, color: met ? 'var(--text-strong)' : 'var(--text-muted)' }}>{label}</span>
      <span style={{ flex: 1, borderBottom: '1px dotted var(--border-card)' }} />
      <span style={{ fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)', color: 'var(--text-muted)' }}>{note}</span>
      <span style={{ fontFamily: 'var(--font-rounded)', fontWeight: 800, fontVariantNumeric: 'tabular-nums', fontSize: fs, color: met ? 'var(--money-in)' : 'var(--text-faint)', minWidth: 56, textAlign: 'right' }}>
        {met ? '+¥' + Math.round(cents / 100) : '¥0'}
      </span>
    </div>
  );
  return (
    <div>
      {lines.map((l, i) => row(l.name, `目标 ${l.goal} 次 · 做到 ${l.doneCount} 次`, l.rewardCents, l.met, i))}
      {bonus ? row('三项全达成奖励', bonus.met ? '达成' : '未达成', bonus.rewardCents, bonus.met, 'bonus') : null}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 'var(--space-4)', paddingTop: 'var(--space-4)', borderTop: '2px solid var(--spruce-700)' }}>
        <Icon name="equal" size={child ? 22 : 18} color="var(--spruce-700)" />
        <span style={{ flex: 1, fontFamily: 'var(--font-rounded)', fontWeight: 800, fontSize: child ? 'var(--type-child-head-size)' : 'var(--type-head-size)', color: 'var(--text-strong)' }}>本周基础零花钱</span>
        <span style={{ fontFamily: 'var(--font-rounded)', fontWeight: 900, fontVariantNumeric: 'tabular-nums', fontSize: child ? 34 : 26, color: 'var(--money-in)' }}>+¥{Math.round(total / 100)}</span>
      </div>
    </div>
  );
}
