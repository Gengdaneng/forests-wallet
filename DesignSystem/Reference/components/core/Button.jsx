import React from 'react';
import { Icon } from './Icon.jsx';

const TONES = {
  primary: { bg: 'var(--action-primary)', press: 'var(--action-primary-press)', fg: 'var(--action-primary-text)', bd: 'transparent' },
  accent:  { bg: 'var(--action-accent)',  press: 'var(--action-accent-press)',  fg: 'var(--action-accent-text)',  bd: 'transparent' },
  quiet:   { bg: 'var(--action-quiet-bg)', press: 'var(--action-quiet-press)',  fg: 'var(--text-body)',           bd: 'transparent' },
  outline: { bg: 'transparent',            press: 'var(--action-quiet-bg)',     fg: 'var(--text-body)',           bd: 'var(--border-strong)' },
  danger:  { bg: 'var(--action-danger)',   press: '#9E3222',                    fg: 'var(--paper-100)',           bd: 'transparent' },
};
const SIZES = {
  child:  { h: 'var(--touch-child)',  px: 'var(--space-7)', fs: 'var(--type-child-label-size)', r: 'var(--radius-xl)', gap: 10 },
  parent: { h: 'var(--touch-parent)', px: 'var(--space-6)', fs: 'var(--type-label-size)',       r: 'var(--radius-md)', gap: 8 },
  small:  { h: '36px',                px: 'var(--space-4)', fs: 'var(--type-caption-size)',     r: 'var(--radius-sm)', gap: 6 },
};

export function Button({ children, tone = 'primary', size = 'parent', icon, iconAfter, block, disabled, onClick, type = 'button', ...rest }) {
  const [held, setHeld] = React.useState(false);
  const t = TONES[tone] || TONES.primary;
  const s = SIZES[size] || SIZES.parent;
  return (
    <button
      type={type}
      disabled={disabled}
      onClick={onClick}
      onPointerDown={() => setHeld(true)}
      onPointerUp={() => setHeld(false)}
      onPointerLeave={() => setHeld(false)}
      style={{
        display: block ? 'flex' : 'inline-flex', width: block ? '100%' : undefined,
        alignItems: 'center', justifyContent: 'center', gap: s.gap,
        minHeight: s.h, padding: `0 ${s.px}`, borderRadius: s.r,
        border: `1.5px solid ${disabled ? 'transparent' : t.bd}`,
        background: disabled ? 'var(--disabled-bg)' : held ? t.press : t.bg,
        color: disabled ? 'var(--disabled-text)' : t.fg,
        fontFamily: 'var(--font-rounded)', fontSize: s.fs, fontWeight: 800,
        letterSpacing: 'var(--tracking-normal)', cursor: disabled ? 'default' : 'pointer',
        transform: held && !disabled ? `scale(${size === 'child' ? 'var(--press-scale-child)' : 'var(--press-scale)'})` : 'scale(1)',
        transition: 'transform var(--dur-instant) var(--ease-standard), background var(--dur-fast) var(--ease-standard)',
        WebkitTapHighlightColor: 'transparent',
      }}
      {...rest}
    >
      {icon ? <Icon name={icon} size={size === 'small' ? 16 : 20} /> : null}
      {children}
      {iconAfter ? <Icon name={iconAfter} size={size === 'small' ? 16 : 20} /> : null}
    </button>
  );
}
