/**
 * Screen title bar. Large rounded title, optional back control and one trailing action.
 */
export interface NavHeaderProps {
  title: string;
  subtitle?: string;
  onBack?: () => void;
  /** Trailing element, usually a Button or IconButton. */
  action?: React.ReactNode;
  size?: 'child' | 'parent';
}
export declare function NavHeader(props: NavHeaderProps): JSX.Element;
