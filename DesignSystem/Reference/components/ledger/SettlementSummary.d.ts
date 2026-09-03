/**
 * Sunday settlement arithmetic, laid out so a 7-year-old can add it up himself —
 * three or four whole numbers and a total (PRD §5.1, §13.4).
 */
export interface SettlementLine {
  name: string;
  goal: number;
  doneCount: number;
  rewardCents: number;
  /** Target hit — partial weeks pay ¥0 for that item, by design. */
  met: boolean;
}
export interface SettlementSummaryProps {
  lines: SettlementLine[];
  /** The all-items bonus line. */
  bonus?: { rewardCents: number; met: boolean };
  size?: 'child' | 'parent';
}
export declare function SettlementSummary(props: SettlementSummaryProps): JSX.Element;
