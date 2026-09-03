/** Square icon-only control. Requires `label` — icons alone are never self-explanatory (PRD §11). */
export interface IconButtonProps {
  icon: string;
  /** Accessible name, also the tooltip. Required. */
  label: string;
  tone?: 'primary' | 'accent' | 'quiet' | 'bare';
  size?: 'child' | 'parent' | 'small';
  onClick?: (e: React.MouseEvent) => void;
  disabled?: boolean;
}
export declare function IconButton(props: IconButtonProps): JSX.Element;
