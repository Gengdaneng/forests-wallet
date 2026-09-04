import React from 'react';
import { Icon } from '../core/Icon.jsx';

const DAYS = ['一', '二', '三', '四', '五', '六', '日'];

const STATES = {
  done:     { bg: 'var(--cell-done-bg)',     ink: 'var(--cell-done-ink)',     border: 'transparent',                 icon: 'check' },
  unlogged: { bg: 'var(--cell-unlogged-bg)', ink: 'var(--text-faint)',        border: 'var(--cell-unlogged-line)',   icon: null },
  future:   { bg: 'var(--cell-future-bg)',   ink: 'var(--cell-future-ink)',   border: 'transparent',                 icon: null },
  missed:   { bg: 'var(--cell-missed-bg)',   ink: 'var(--cell-missed-ink)',   border: 'transparent',                 icon: 'minus' },
};

export function BoardCell({ state = 'unlogged', onToggle, size = 'child' }) {
  const s = STATES[state] || STATES.unlogged;
  const dim = size === 'child' ? 54 : 44;
  const interactive = !!onToggle && state !== 'future';
  return (
    <button type="button" disabled={!interactive} onClick={onToggle}
      aria-label={{ done: '已完成', unlogged: '还没记', future: '还没到', missed: '未达成' }[state]}
      style={{
        width: dim, height: dim, borderRadius: 'var(--radius-cell)',
        background: s.bg, color: s.ink,
        border: s.border === 'transparent' ? '1.5px solid transparent' : `1.5px dashed ${s.border}`,
        display: 'grid', placeItems: 'center',
        cursor: interactive ? 'pointer' : 'default',
        transition: 'background var(--dur-fast) var(--ease-standard), transform var(--dur-instant) var(--ease-bounce)',
      }}>
      {s.icon ? <Icon name={s.icon} size={size === 'child' ? 26 : 20} strokeWidth={3} /> : null}
    </button>
  );
}

export function WeekBoard({ items, size = 'child', onToggle, weekLabel }) {
  const child = size === 'child';
  const cell = child ? 54 : 44;
  return (
    <div>
      {weekLabel ? (
        <div style={{ marginBottom: 'var(--space-4)', fontFamily: 'var(--font-rounded)', fontWeight: 800, fontSize: child ? 'var(--type-child-head-size)' : 'var(--type-head-size)', color: 'var(--text-strong)' }}>{weekLabel}</div>
      ) : null}
      <div style={{ display: 'grid', gridTemplateColumns: `minmax(96px,1fr) repeat(7, ${cell}px)`, gap: child ? 10 : 6, alignItems: 'center' }}>
        <div />
        {DAYS.map((d) => (
          <div key={d} style={{ textAlign: 'center', fontFamily: 'var(--font-rounded)', fontWeight: 700, fontSize: child ? 17 : 13, color: 'var(--text-muted)' }}>{d}</div>
        ))}
        {items.map((it, r) => (
          <React.Fragment key={it.name}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 2, paddingRight: 8 }}>
              <span style={{ fontFamily: 'var(--font-rounded)', fontWeight: 700, fontSize: child ? 'var(--type-child-body-size)' : 'var(--type-label-size)', color: 'var(--text-strong)' }}>{it.name}</span>
              <span style={{ fontSize: child ? 15 : 12, color: 'var(--text-muted)', fontVariantNumeric: 'tabular-nums' }}>
                {it.days.filter((s) => s === 'done').length}/{it.goal} · ¥{Math.round(it.rewardCents / 100)}
              </span>
            </div>
            {it.days.map((st, c) => (
              <div key={c} style={{ display: 'grid', placeItems: 'center' }}>
                <BoardCell state={st} size={size} onToggle={onToggle ? () => onToggle(r, c) : undefined} />
              </div>
            ))}
          </React.Fragment>
        ))}
      </div>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: child ? 20 : 14, marginTop: 'var(--space-5)', fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-caption-size)', color: 'var(--text-muted)' }}>
        {[['done', '做到了'], ['unlogged', '爸爸还没记'], ['future', '还没到']].map(([k, label]) => (
          <span key={k} style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <span style={{ width: 18, height: 18, borderRadius: 5, background: STATES[k].bg, border: STATES[k].border === 'transparent' ? 'none' : `1.5px dashed ${STATES[k].border}` }} />{label}
          </span>
        ))}
      </div>
    </div>
  );
}
