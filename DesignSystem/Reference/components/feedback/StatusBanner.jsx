import React from 'react';
import { Icon } from '../core/Icon.jsx';

const KINDS = {
  offline: { icon: 'cloud-off', bg: 'var(--slate-100)', fg: 'var(--slate-600)', text: '正在显示已保存的信息' },
  failed:  { icon: 'refresh-cw-off', bg: 'var(--money-out-bg)', fg: 'var(--money-out)', text: '更新失败，这是上次保存的信息' },
  online:  { icon: 'check-circle-2', bg: 'var(--money-in-bg)', fg: 'var(--money-in)', text: '信息是最新的' },
  norealmoney: { icon: 'shield-check', bg: 'var(--surface-sunken)', fg: 'var(--text-muted)', text: '只是记账，没有真的钱在动' },
};

export function StatusBanner({ kind = 'offline', text, size = 'child', style }) {
  const k = KINDS[kind] || KINDS.offline;
  const child = size === 'child';
  return (
    <div role="status" style={{
      display: 'flex', alignItems: 'center', gap: 10,
      background: k.bg, color: k.fg, borderRadius: 'var(--radius-pill)',
      padding: child ? '10px 18px' : '8px 14px',
      fontFamily: 'var(--font-text)', fontWeight: 600,
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)', ...style,
    }}>
      <Icon name={k.icon} size={child ? 20 : 16} />{text || k.text}
    </div>
  );
}
