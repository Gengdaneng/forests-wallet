import React from 'react';

export function Card({ children, variant = 'parent', tone = 'paper', pad, onClick, style, ...rest }) {
  const tones = {
    paper: { bg: 'var(--surface-card)', bd: 'var(--border-card)', fg: 'var(--text-body)' },
    sunken: { bg: 'var(--surface-sunken)', bd: 'transparent', fg: 'var(--text-body)' },
    leaf: { bg: 'var(--surface-leaf)', bd: 'transparent', fg: 'var(--spruce-800)' },
    honey: { bg: 'var(--surface-honey)', bd: 'transparent', fg: 'var(--text-on-honey)' },
    ink: { bg: 'var(--surface-ink)', bd: 'transparent', fg: 'var(--text-on-ink)' },
  };
  const t = tones[tone] || tones.paper;
  const child = variant === 'child';
  return (
    <div onClick={onClick} style={{
      background: t.bg, color: t.fg,
      border: `1px solid ${t.bd}`,
      borderRadius: child ? 'var(--radius-card-child)' : 'var(--radius-card-parent)',
      padding: pad ?? (child ? 'var(--card-pad-child)' : 'var(--card-pad-parent)'),
      boxShadow: tone === 'sunken' ? 'none' : child ? 'var(--shadow-card-child)' : 'var(--shadow-card)',
      cursor: onClick ? 'pointer' : undefined, ...style,
    }} {...rest}>{children}</div>
  );
}
