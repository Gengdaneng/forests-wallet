import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function GoalProgress({ title, savedCents, targetCents, size = 'child', reached, style }) {
  const saved = Math.max(0, Math.round(savedCents / 100));
  const target = Math.round(targetCents / 100);
  const pct = Math.min(100, Math.round((saved / Math.max(1, target)) * 100));
  const left = Math.max(0, target - saved);
  const child = size === 'child';
  return (
    <div style={{ ...style }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: child ? 'var(--space-4)' : 'var(--space-3)' }}>
        <Icon name="target" size={child ? 26 : 20} color="var(--honey-700)" />
        <span style={{ fontFamily: 'var(--font-rounded)', fontWeight: 800, fontSize: child ? 'var(--type-child-head-size)' : 'var(--type-head-size)', color: 'var(--text-strong)' }}>{title}</span>
      </div>
      <div style={{ height: child ? 20 : 12, borderRadius: 'var(--radius-pill)', background: 'var(--money-goal-track)', overflow: 'hidden' }}>
        <div style={{
          width: pct + '%', height: '100%', borderRadius: 'var(--radius-pill)',
          background: reached ? 'var(--leaf-500)' : 'var(--money-goal)',
          transition: 'width var(--dur-slow) var(--ease-out)',
        }} />
      </div>
      {/* PRD §11: progress is always written out in numbers, not only drawn */}
      <div style={{ display: 'flex', justifyContent: 'space-between', gap: 12, marginTop: child ? 'var(--space-4)' : 'var(--space-3)', fontFamily: 'var(--font-rounded)', fontWeight: 700, fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-label-size)', color: 'var(--text-body)' }}>
        <span style={{ fontVariantNumeric: 'tabular-nums' }}>已攒 ¥{saved} / ¥{target}</span>
        <span style={{ color: reached ? 'var(--money-in)' : 'var(--honey-700)' }}>
          {reached ? '你可以买了' : `还差 ¥${left}`}
        </span>
      </div>
    </div>
  );
}
