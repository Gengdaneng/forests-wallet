import React from 'react';
import { Tag, CATEGORIES } from '../core/Tag.jsx';

export function CategoryPicker({ value, onChange, size = 'parent', label = '花在什么上' }) {
  return (
    <div>
      {label ? <div style={{ display: 'flex', gap: 8, alignItems: 'baseline', marginBottom: 'var(--space-3)', fontFamily: 'var(--font-text)', fontWeight: 600, fontSize: 'var(--type-label-size)', color: 'var(--text-body)' }}>
        {label}<span style={{ fontSize: 'var(--type-caption-size)', color: 'var(--text-faint)' }}>可跳过，默认「其他」</span>
      </div> : null}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 'var(--space-3)' }}>
        {CATEGORIES.map((c) => (
          <Tag key={c.id} category={c.id} size={size} selected={value === c.id}
            onClick={() => onChange && onChange(value === c.id ? undefined : c.id)} />
        ))}
      </div>
    </div>
  );
}
