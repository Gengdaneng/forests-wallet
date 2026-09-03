import React from 'react';
import { Icon } from './Icon.jsx';

export function IconButton({ icon, label, tone = 'quiet', size = 'parent', onClick, disabled, ...rest }) {
  const [held, setHeld] = React.useState(false);
  const dim = size === 'child' ? 54 : size === 'small' ? 36 : 48;
  const bg = tone === 'primary' ? 'var(--action-primary)' : tone === 'accent' ? 'var(--action-accent)' : tone === 'bare' ? 'transparent' : 'var(--action-quiet-bg)';
  const fg = tone === 'primary' ? 'var(--action-primary-text)' : tone === 'accent' ? 'var(--action-accent-text)' : 'var(--text-body)';
  return (
    <button type="button" aria-label={label} title={label} disabled={disabled} onClick={onClick}
      onPointerDown={() => setHeld(true)} onPointerUp={() => setHeld(false)} onPointerLeave={() => setHeld(false)}
      style={{
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        width: dim, height: dim, borderRadius: size === 'child' ? 'var(--radius-lg)' : 'var(--radius-md)',
        border: 'none', background: disabled ? 'var(--disabled-bg)' : bg, color: disabled ? 'var(--disabled-text)' : fg,
        cursor: disabled ? 'default' : 'pointer',
        transform: held && !disabled ? 'scale(var(--press-scale))' : 'scale(1)',
        transition: 'transform var(--dur-instant) var(--ease-standard), background var(--dur-fast) var(--ease-standard)',
        WebkitTapHighlightColor: 'transparent',
      }} {...rest}>
      <Icon name={icon} size={size === 'small' ? 18 : 24} />
    </button>
  );
}
