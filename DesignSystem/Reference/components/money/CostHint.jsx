import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function CostHint({ cents, goalTitle, style }) {
  const yuan = Math.round(Math.abs(cents) / 100);
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      background: 'var(--surface-honey)', borderRadius: 'var(--radius-lg)',
      padding: 'var(--space-4) var(--space-5)', color: 'var(--text-on-honey)',
      fontFamily: 'var(--font-text)', fontWeight: 600, fontSize: 'var(--type-body-size)', ...style,
    }}>
      <Icon name="move-right" size={20} color="var(--honey-700)" />
      <span>离{goalTitle ? `「${goalTitle}」` : '你的目标'}又远了 ¥{yuan}</span>
    </div>
  );
}
