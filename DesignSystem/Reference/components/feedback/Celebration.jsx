import React from 'react';
import { AmountText } from '../money/AmountText.jsx';

/** Income only. Spend, debt and corrections get one quiet static acknowledgement (PRD §10). */
export function Celebration({ cents, reason, show = true, onDone, reducedMotion }) {
  React.useEffect(() => {
    if (!show || !onDone) return;
    const t = setTimeout(onDone, 1800);
    return () => clearTimeout(t);
  }, [show, onDone]);
  if (!show) return null;
  const still = reducedMotion || (typeof window !== 'undefined' && window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
  const leaves = [-160, -95, -30, 35, 100, 165];
  return (
    <div role="status" style={{ position: 'relative', display: 'grid', placeItems: 'center', padding: 'var(--space-9) var(--space-7)', background: 'var(--surface-leaf)', borderRadius: 'var(--radius-2xl)', overflow: 'hidden' }}>
      {!still && leaves.map((x, i) => (
        <span key={i} aria-hidden="true" style={{
          position: 'absolute', top: -24, left: `calc(50% + ${x}px)`,
          width: 14, height: 14, borderRadius: '14px 2px 14px 2px',
          background: i % 2 ? 'var(--honey-500)' : 'var(--leaf-500)',
          animation: `fwFall var(--dur-celebrate) var(--ease-out) ${i * 70}ms both`,
        }} />
      ))}
      <div style={{ fontFamily: 'var(--font-rounded)', fontWeight: 800, fontSize: 'var(--type-child-head-size)', color: 'var(--spruce-700)' }}>加进来了</div>
      <div style={{ marginTop: 'var(--space-3)', animation: still ? 'none' : 'fwPop var(--dur-celebrate) var(--ease-bounce) both' }}>
        <AmountText cents={cents} direction="in" size="heroSm" />
      </div>
      {reason ? <div style={{ marginTop: 'var(--space-3)', fontFamily: 'var(--font-text)', fontSize: 'var(--type-child-body-size)', color: 'var(--spruce-600)' }}>{reason}</div> : null}
      <style>{'@keyframes fwFall{0%{transform:translateY(0) rotate(0);opacity:0}20%{opacity:1}100%{transform:translateY(240px) rotate(220deg);opacity:0}}@keyframes fwPop{0%{transform:scale(.6);opacity:0}60%{transform:scale(1.06)}100%{transform:scale(1);opacity:1}}'}</style>
    </div>
  );
}
