/**
 * Whole-yuan keypad. The entry flow is 3 taps / 15 seconds and no field is required —
 * parental laziness is the project's number-one risk (PRD §6.3).
 */
export interface NumberPadProps {
  /** Digit string of whole yuan, e.g. "15". */
  value?: string;
  onChange?: (next: string) => void;
  /** Max digits. Default 5. */
  max?: number;
}
export declare function NumberPad(props: NumberPadProps): JSX.Element;
