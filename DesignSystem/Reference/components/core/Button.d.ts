/**
 * Primary action control. Labels are direct verbs ("记一笔", "确认"), never "转账".
 */
export interface ButtonProps {
  children?: React.ReactNode;
  /** primary = spruce ink · accent = pocket-money honey · quiet · outline · danger */
  tone?: 'primary' | 'accent' | 'quiet' | 'outline' | 'danger';
  /** child = 54px targets (iPad) · parent = 48px (iPhone) · small = 36px inline */
  size?: 'child' | 'parent' | 'small';
  /** Lucide icon name before the label. */
  icon?: string;
  /** Lucide icon name after the label. */
  iconAfter?: string;
  block?: boolean;
  disabled?: boolean;
  onClick?: (e: React.MouseEvent) => void;
  type?: 'button' | 'submit';
}
export declare function Button(props: ButtonProps): JSX.Element;
