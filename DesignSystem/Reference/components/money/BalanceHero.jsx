import React from 'react';
import { AmountText } from './AmountText.jsx';
import { Icon } from '../core/Icon.jsx';

export function BalanceHero({ cents, caption = '你现在有', size = 'child', note, style }) {
  const negative = cents < 0;
  const child = size === 'child';
  return (
    <div style={{
      background: negative ? 'var(--money-debt-bg)' : 'var(--surface-ink)',
      color: negative ? 'var(--money-debt)' : 'var(--text-on-ink)',
      border: negative ? '1.5px solid var(--berry-400)' : 'none',
      borderRadius: child ? 'var(--radius-2xl)' : 'var(--radius-lg)',
      padding: child ? 'var(--space-9) var(--space-8)' : 'var(--space-6)',
      textAlign: child ? 'center' : 'left', ...style,
    }}>
      <div style={{
        fontFamily: 'var(--font-rounded)', fontWeight: 700,
        fontSize: child ? 'var(--type-child-head-size)' : 'var(--type-label-size)',
        color: negative ? 'var(--money-debt)' : 'var(--text-on-ink-muted)',
        marginBottom: child ? 'var(--space-4)' : 'var(--space-2)',
      }}>{negative ? '你现在欠爸爸' : caption}</div>
      <AmountText cents={cents} size={child ? 'hero' : 'heroSm'} showSign={false}
        direction="flat" style={{ color: negative ? 'var(--money-debt)' : 'var(--paper-000)' }} />
      {negative ? (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: child ? 'center' : 'flex-start', gap: 8, marginTop: 'var(--space-4)', fontFamily: 'var(--font-text)', fontWeight: 600, fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)' }}>
          <Icon name="alert-triangle" size={child ? 22 : 18} />下次零花钱会先还上
        </div>
      ) : note ? (
        <div style={{ marginTop: 'var(--space-4)', fontFamily: 'var(--font-text)', fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-caption-size)', color: 'var(--text-on-ink-muted)' }}>{note}</div>
      ) : null}
    </div>
  );
}
