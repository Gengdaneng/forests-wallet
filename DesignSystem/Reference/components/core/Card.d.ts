/** Paper card: hairline border + short warm shadow. 24px radius for Forrest, 16px for Dad. */
export interface CardProps {
  children?: React.ReactNode;
  /** child = 24px radius / 24px padding · parent = 16px / 16px */
  variant?: 'child' | 'parent';
  tone?: 'paper' | 'sunken' | 'leaf' | 'honey' | 'ink';
  /** Override padding. */
  pad?: number | string;
  onClick?: () => void;
  style?: React.CSSProperties;
}
export declare function Card(props: CardProps): JSX.Element;
