/** Small state pill. Money tones carry an icon as well as a colour — never colour alone (PRD §11). */
export interface BadgeProps {
  children?: React.ReactNode;
  tone?: 'in' | 'out' | 'fix' | 'debt' | 'goal' | 'neutral';
  icon?: string;
  size?: 'child' | 'parent';
}
export declare function Badge(props: BadgeProps): JSX.Element;
