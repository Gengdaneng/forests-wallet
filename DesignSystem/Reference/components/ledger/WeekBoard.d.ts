/**
 * The 7-day × N-item check-in board. Cells are TRI-state: a day Dad hasn't logged yet
 * shows an empty dashed cell and reads "还没记" — never a cross. Only Sunday settlement
 * turns still-empty cells into 未达成 (PRD §5.3).
 * @startingPoint section="Ledger" subtitle="Tri-state week board, rules, settlement" viewport="700x340"
 */
export interface WeekBoardItem {
  /** Check-in item name, e.g. "跳绳". */
  name: string;
  /** Weekly target count. */
  goal: number;
  /** Reward for hitting the target, in cents. */
  rewardCents: number;
  /** Exactly 7 states, Monday first. */
  days: ('done' | 'unlogged' | 'future' | 'missed')[];
}
export interface WeekBoardProps {
  items: WeekBoardItem[];
  size?: 'child' | 'parent';
  /** Parent side only — Forrest's view is strictly read-only. (row, col) => void */
  onToggle?: (row: number, col: number) => void;
  weekLabel?: string;
}
export declare function WeekBoard(props: WeekBoardProps): JSX.Element;
export declare function BoardCell(props: { state?: 'done' | 'unlogged' | 'future' | 'missed'; onToggle?: () => void; size?: 'child' | 'parent' }): JSX.Element;
