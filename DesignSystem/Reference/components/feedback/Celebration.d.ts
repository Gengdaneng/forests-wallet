/**
 * The one celebratory moment in the product: money actually arrived. Falling leaves +
 * the amount popping in. Bound to a REAL event, never to app usage; degrades to a static
 * panel under prefers-reduced-motion (PRD §10).
 */
export interface CelebrationProps {
  /** Income amount in cents. */
  cents: number;
  /** Why it came, e.g. "本周基础零花钱". */
  reason?: string;
  show?: boolean;
  /** Called ~1.8s after appearing. */
  onDone?: () => void;
  /** Force the static variant. */
  reducedMotion?: boolean;
}
export declare function Celebration(props: CelebrationProps): JSX.Element | null;
