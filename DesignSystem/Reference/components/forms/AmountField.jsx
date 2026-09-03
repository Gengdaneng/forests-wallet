import React from 'react';

export function AmountField({ value = '', direction = 'in', label }) {
  const color = direction === 'out' ? 'var(--money-out)' : direction === 'fix' ? 'var(--money-fix)' : 'var(--money-in)';
  const sign = direction === 'out' ? '−' : direction === 'fix' ? '±' : '+';
  return (
    <div style={{ textAlign: 'center', padding: 'var(--space-6) 0' }}>
      {label ? <div style={{ fontFamily: 'var(--font-text)', fontWeight: 600, fontSize: 'var(--type-label-size)', color: 'var(--text-muted)', marginBottom: 'var(--space-3)' }}>{label}</div> : null}
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'center', gap: 4, color, fontFamily: 'var(--font-rounded)', fontWeight: 900, letterSpacing: 'var(--tracking-tight)' }}>
        <span style={{ fontSize: 40 }}>{sign}¥</span>
        <span style={{ fontSize: 64, fontVariantNumeric: 'tabular-nums' }}>{value || '0'}</span>
        <span aria-hidden="true" style={{ width: 3, height: 48, marginLeft: 4, background: color, borderRadius: 2, animation: 'fwCaret 1s steps(2,end) infinite' }} />
      </div>
      <style>{'@keyframes fwCaret{50%{opacity:0}}'}</style>
    </div>
  );
}
