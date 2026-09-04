/** Renders a cent amount as whole yuan with a direction sign and colour. */
export interface AmountTextProps {
  /** Amount in cents (integer). Negative values default to the debt tone. */
  cents: number;
  /** in = income · out = spend · fix = correction · debt = negative balance · flat = plain */
  direction?: 'in' | 'out' | 'fix' | 'debt' | 'flat';
  /** hero = 96px balance · heroSm = 56px · row = 22px list figure · small = 17px */
  size?: 'hero' | 'heroSm' | 'row' | 'small';
  showSign?: boolean;
  style?: React.CSSProperties;
}
export declare function AmountText(props: AmountTextProps): JSX.Element;
/** cents → "1,234" (whole yuan, no decimals). */
export declare function formatYuan(cents: number): string;
