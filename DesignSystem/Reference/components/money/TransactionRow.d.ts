/** One immutable ledger line. Shows the running balance so Forrest can count backwards and verify. */
export interface TransactionRowProps {
  /** The 2–8 character reason, e.g. "买冰淇淋". */
  reason: string;
  cents: number;
  direction?: 'in' | 'out' | 'fix';
  /** Display date string, e.g. "10月3日". */
  date?: string;
  /** Category id — its emoji replaces the direction glyph. */
  category?: 'food' | 'toy' | 'game' | 'book' | 'gift' | 'other';
  /** Balance after this line, in cents. Always pass it on Forrest's screens. */
  balanceAfter?: number;
  size?: 'child' | 'parent';
  /** This record has been reversed by a correction — struck through, never deleted. */
  reversed?: boolean;
  onClick?: () => void;
}
export declare function TransactionRow(props: TransactionRowProps): JSX.Element;
