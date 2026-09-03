import React from 'react';

/** The 6 fixed spend categories from PRD §6.2. Emoji is the brand's category glyph set. */
export const CATEGORIES = [
  { id: 'food', emoji: '🍦', label: '吃的' },
  { id: 'toy', emoji: '🧸', label: '玩具' },
  { id: 'game', emoji: '🎮', label: '游戏' },
  { id: 'book', emoji: '📚', label: '书和文具' },
  { id: 'gift', emoji: '🎁', label: '送人的礼物' },
  { id: 'other', emoji: '❓', label: '其他' },
];

export function Tag({ category, label, emoji, selected, onClick, size = 'parent' }) {
  const c = CATEGORIES.find((x) => x.id === category);
  const text = label ?? (c ? c.label : '');
  const glyph = emoji ?? (c ? c.emoji : null);
  const child = size === 'child';
  return (
    <span role={onClick ? 'button' : undefined} onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', gap: 8,
      minHeight: onClick ? (child ? 'var(--touch-child)' : 'var(--touch-parent)') : undefined,
      padding: child ? '10px 18px' : '8px 14px',
      borderRadius: 'var(--radius-pill)',
      background: selected ? 'var(--surface-leaf)' : 'var(--surface-sunken)',
      border: `1.5px solid ${selected ? 'var(--leaf-500)' : 'transparent'}`,
      color: 'var(--text-body)', fontFamily: 'var(--font-text)', fontWeight: 600,
      fontSize: child ? 'var(--type-child-label-size)' : 'var(--type-label-size)',
      cursor: onClick ? 'pointer' : 'default', whiteSpace: 'nowrap',
      transition: 'background var(--dur-fast) var(--ease-standard)',
    }}>
      {glyph ? <span style={{ fontSize: child ? 22 : 18, lineHeight: 1 }}>{glyph}</span> : null}{text}
    </span>
  );
}
