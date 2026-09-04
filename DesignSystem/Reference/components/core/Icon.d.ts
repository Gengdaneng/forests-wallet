/** Lucide line icon at brand stroke weight. Always pair an icon with text (PRD §11). */
export interface IconProps {
  /** Lucide icon name, kebab-case, e.g. "wallet", "piggy-bank", "rotate-ccw". */
  name: string;
  /** Square size in px. Default 24. */
  size?: number;
  /** Default 2 — the brand stroke weight. */
  strokeWidth?: number;
  color?: string;
  /** Accessible label. Omit for decorative icons (they become aria-hidden). */
  label?: string;
  style?: React.CSSProperties;
}
export declare function Icon(props: IconProps): JSX.Element;
