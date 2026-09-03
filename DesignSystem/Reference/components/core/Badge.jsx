import React from 'react';
import { Icon } from './Icon.jsx';

const TONES = {
  in:   { bg: 'var(--money-in-bg)',   fg: 'var(--money-in)' },
  out:  { bg: 'var(--money-out-bg)',  fg: 'var(--money-out)' },
  fix:  { bg: 'var(--money-fix-bg)',  fg: 'var(--money-fix)' },
  debt: { bg: 'var(--money-debt-bg)', fg: 'var(--money-debt)' },
  goal: { bg: 'var(--money-goal-track)', fg: 'var(--honey-700)' },
  neutral: { bg: 'var(--surface-sunken)', fg: 'var(--text-muted)' },
};

export function Badge({ children, tone = 'neutral', icon, size = 'parent' }) {
  const t = TONES[tone] || TONES.neutral;
  const child = size === 'child';
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      background: t.bg, color: t.fg,
      padding: child ? '6px 14px' : '4px 10px', borderRadius: 'var(--radius-pill)',
      fontFamily: 'var(--font-rounded)', fontWeight: 800,
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)',
      whiteSpace: 'nowrap',
    }}>
      {icon ? <Icon name={icon} size={child ? 18 : 14} /> : null}{children}
    </span>
  );
}
