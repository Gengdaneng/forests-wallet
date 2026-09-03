import React from 'react';

/* Forrest's Wallet uses Lucide (line icons, 2px stroke) as its icon set — see
   readme.md ICONOGRAPHY. The Lucide UMD build must be on the page:
   <script src="https://unpkg.com/lucide@0.544.0/dist/umd/lucide.js"></script> */
export function Icon({ name, size = 24, strokeWidth = 2, color = 'currentColor', label, style, ...rest }) {
  const ref = React.useRef(null);
  React.useEffect(() => {
    if (window.lucide && window.lucide.createIcons) window.lucide.createIcons();
  });
  return (
    <i
      ref={ref}
      data-lucide={name}
      width={size}
      height={size}
      stroke-width={strokeWidth}
      aria-hidden={label ? undefined : 'true'}
      aria-label={label}
      style={{ display: 'inline-flex', width: size, height: size, color, flex: '0 0 auto', ...style }}
      {...rest}
    />
  );
}
