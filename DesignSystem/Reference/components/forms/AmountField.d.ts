/** Large read-only amount display that sits above the NumberPad. Whole yuan, signed and coloured. */
export interface AmountFieldProps {
  /** Digit string from NumberPad. */
  value?: string;
  direction?: 'in' | 'out' | 'fix';
  /** Small lead-in, e.g. "加进来多少". */
  label?: string;
}
export declare function AmountField(props: AmountFieldProps): JSX.Element;
