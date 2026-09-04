/**
 * The balance panel — the single reason Forrest opens the app. Flips to the loud
 * debt treatment (berry ground + icon + words, not colour alone) when negative.
 */
export interface BalanceHeroProps {
  /** Balance in cents; may be negative. */
  cents: number;
  /** Child-voice lead-in. Default "你现在有". Ignored when negative. */
  caption?: string;
  /** child = 96px figure on ink, centred · parent = 56px, left aligned */
  size?: 'child' | 'parent';
  /** Small supporting line, e.g. the trust/offline note. */
  note?: string;
  style?: React.CSSProperties;
}
export declare function BalanceHero(props: BalanceHeroProps): JSX.Element;
