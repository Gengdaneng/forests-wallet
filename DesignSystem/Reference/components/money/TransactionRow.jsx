import React from 'react';
import { AmountText } from './AmountText.jsx';
import { Icon } from '../core/Icon.jsx';
import { CATEGORIES } from '../core/Tag.jsx';

const KIND = {
  in:  { icon: 'arrow-down-left', bg: 'var(--money-in-bg)',  fg: 'var(--money-in)' },
  out: { icon: 'arrow-up-right',  bg: 'var(--money-out-bg)', fg: 'var(--money-out)' },
  fix: { icon: 'rotate-ccw',      bg: 'var(--money-fix-bg)', fg: 'var(--money-fix)' },
};

export function TransactionRow({ reason, cents, direction = 'in', date, category, balanceAfter, size = 'child', reversed, onClick }) {
  const k = KIND[direction] || KIND.in;
  const cat = CATEGORIES.find((c) => c.id === category);
  const child = size === 'child';
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: child ? 'var(--space-5)' : 'var(--space-4)',
      minHeight: child ? 'var(--touch-child)' : 'var(--touch-parent)',
      padding: child ? 'var(--space-4) 0' : 'var(--space-3) 0',
      cursor: onClick ? 'pointer' : undefined, opacity: reversed ? 0.55 : 1,
    }}>
      <div style={{
        display: 'grid', placeItems: 'center', flex: '0 0 auto',
        width: child ? 48 : 40, height: child ? 48 : 40,
        borderRadius: 'var(--radius-md)', background: k.bg, color: k.fg,
      }}>{cat ? <span style={{ fontSize: child ? 24 : 20 }}>{cat.emoji}</span> : <Icon name={k.icon} size={child ? 24 : 20} />}</div>

      <div style={{ minWidth: 0, flex: 1 }}>
        <div style={{
          fontFamily: 'var(--font-rounded)', fontWeight: 700,
          fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)',
          color: 'var(--text-strong)', textDecoration: reversed ? 'line-through' : 'none',
          overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
        }}>{reason}</div>
        <div style={{ display: 'flex', gap: 8, marginTop: 2, fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)', color: 'var(--text-muted)' }}>
          <span>{date}</span>{reversed ? <span>· 已改正</span> : null}
        </div>
      </div>

      <div style={{ textAlign: 'right', flex: '0 0 auto' }}>
        <AmountText cents={cents} direction={direction} size={child ? 'row' : 'small'} />
        {balanceAfter !== undefined ? (
          <div style={{ marginTop: 2, fontFamily: 'var(--font-mono)', fontSize: child ? 15 : 12, color: 'var(--text-faint)' }}>
            剩 ¥{Math.round(balanceAfter / 100)}
          </div>
        ) : null}
      </div>
    </div>
  );
}
