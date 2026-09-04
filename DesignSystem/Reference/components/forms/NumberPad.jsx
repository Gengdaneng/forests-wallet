import React from 'react';
import { Icon } from '../core/Icon.jsx';

const KEYS = ['1','2','3','4','5','6','7','8','9','clear','0','back'];

export function NumberPad({ value = '', onChange, max = 5 }) {
  const press = (k) => {
    if (!onChange) return;
    if (k === 'back') return onChange(value.slice(0, -1));
    if (k === 'clear') return onChange('');
    if (value.length >= max) return;
    if (k === '0' && value === '') return;
    onChange(value + k);
  };
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 'var(--space-4)' }}>
      {KEYS.map((k) => <PadKey key={k} k={k} onPress={() => press(k)} />)}
    </div>
  );
}

function PadKey({ k, onPress }) {
  const [held, setHeld] = React.useState(false);
  const glyph = k === 'back' ? <Icon name="delete" size={24} /> : k === 'clear' ? <Icon name="eraser" size={24} /> : k;
  return (
    <button type="button" onClick={onPress}
      aria-label={k === 'back' ? '删除' : k === 'clear' ? '清空' : k}
      onPointerDown={() => setHeld(true)} onPointerUp={() => setHeld(false)} onPointerLeave={() => setHeld(false)}
      style={{
        minHeight: 62, border: 'none', borderRadius: 'var(--radius-md)',
        background: k === 'back' || k === 'clear' ? 'transparent' : held ? 'var(--action-quiet-press)' : 'var(--surface-card)',
        boxShadow: k === 'back' || k === 'clear' ? 'none' : 'var(--shadow-card)',
        color: 'var(--text-strong)', fontFamily: 'var(--font-rounded)', fontWeight: 800, fontSize: 28,
        display: 'grid', placeItems: 'center', cursor: 'pointer',
        transform: held ? 'scale(var(--press-scale))' : 'scale(1)',
        transition: 'transform var(--dur-instant) var(--ease-standard), background var(--dur-fast) var(--ease-standard)',
        WebkitTapHighlightColor: 'transparent',
      }}>{glyph}</button>
  );
}
