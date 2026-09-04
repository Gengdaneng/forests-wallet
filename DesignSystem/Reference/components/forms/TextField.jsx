import React from 'react';

export function TextField({ label, value, onChange, placeholder, optional, maxLength, size = 'parent' }) {
  const [focus, setFocus] = React.useState(false);
  const child = size === 'child';
  return (
    <label style={{ display: 'block' }}>
      {label ? (
        <span style={{ display: 'flex', gap: 8, alignItems: 'baseline', marginBottom: 'var(--space-3)', fontFamily: 'var(--font-text)', fontWeight: 600, fontSize: 'var(--type-label-size)', color: 'var(--text-body)' }}>
          {label}{optional ? <span style={{ fontSize: 'var(--type-caption-size)', color: 'var(--text-faint)' }}>可跳过</span> : null}
        </span>
      ) : null}
      <input value={value} placeholder={placeholder} maxLength={maxLength}
        onChange={(e) => onChange && onChange(e.target.value)}
        onFocus={() => setFocus(true)} onBlur={() => setFocus(false)}
        style={{
          width: '100%', minHeight: child ? 'var(--touch-child)' : 'var(--touch-parent)',
          padding: '0 var(--space-4)', borderRadius: 'var(--radius-control)',
          border: `1.5px solid ${focus ? 'var(--spruce-500)' : 'var(--border-card)'}`,
          background: 'var(--surface-card)', color: 'var(--text-strong)',
          fontFamily: 'var(--font-text)', fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-body-size)',
          boxShadow: focus ? 'var(--shadow-focus)' : 'none', outline: 'none',
          transition: 'border-color var(--dur-fast) var(--ease-standard), box-shadow var(--dur-fast) var(--ease-standard)',
        }} />
    </label>
  );
}
