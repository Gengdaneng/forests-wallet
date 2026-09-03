import React from 'react';

/** Money is stored in cents and always displayed as whole yuan (PRD §3). */
export function formatYuan(cents) {
  const yuan = Math.round(Math.abs(cents) / 100);
  return yuan.toLocaleString('zh-CN');
}

const DIR = {
  in:   { color: 'var(--money-in)',   sign: '+' },
  out:  { color: 'var(--money-out)',  sign: '−' },
  fix:  { color: 'var(--money-fix)',  sign: '±' },
  debt: { color: 'var(--money-debt)', sign: '−' },
  flat: { color: 'var(--text-body)',  sign: '' },
};

export function AmountText({ cents, direction, size = 'row', showSign = true, style }) {
  const dir = direction || (cents < 0 ? 'debt' : cents > 0 ? 'in' : 'flat');
  const d = DIR[dir] || DIR.flat;
  const sizes = {
    hero: { fs: 'var(--type-balance-size)', fw: 900, lh: 'var(--type-balance-lh)' },
    heroSm: { fs: 'var(--type-balance-sm-size)', fw: 900, lh: 'var(--type-balance-sm-lh)' },
    row: { fs: 'var(--type-amount-size)', fw: 'var(--type-amount-weight)', lh: 1.1 },
    small: { fs: 'var(--type-amount-sm-size)', fw: 700, lh: 1.2 },
  };
  const s = sizes[size] || sizes.row;
  return (
    <span style={{
      fontFamily: 'var(--font-rounded)', fontVariantNumeric: 'tabular-nums',
      fontSize: s.fs, fontWeight: s.fw, lineHeight: s.lh,
      letterSpacing: 'var(--tracking-tight)', color: d.color, whiteSpace: 'nowrap', ...style,
    }}>
      {showSign && d.sign ? d.sign : ''}¥{formatYuan(cents)}
    </span>
  );
}
