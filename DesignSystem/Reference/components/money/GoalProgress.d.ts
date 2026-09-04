/**
 * The single savings goal. Writes the figures out (`已攒 ¥87 / ¥400`) as well as drawing the bar.
 * Never shows an estimated number of weeks — four months reads as "never" to a 7-year-old (PRD §8.3).
 */
export interface GoalProgressProps {
  /** What he's saving for, in his words, e.g. "乐高赛车". */
  title: string;
  savedCents: number;
  targetCents: number;
  size?: 'child' | 'parent';
  /** Target met — bar turns leaf green and the label reads 你可以买了. Money is NOT deducted. */
  reached?: boolean;
  style?: React.CSSProperties;
}
export declare function GoalProgress(props: GoalProgressProps): JSX.Element;
