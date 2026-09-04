/** One rule in the rule list: condition, status, amount. Explains, never blames (PRD §9.1). */
export interface RuleRowProps {
  name: string;
  /** The condition in plain words, e.g. "每周 5 次". */
  detail?: string;
  rewardCents: number;
  /** true 做到了 · false 还没记 · undefined hides the badge (rule management view). */
  met?: boolean;
  size?: 'child' | 'parent';
  /** base = weekly conditional allowance · adhoc = one-off agreed reward */
  kind?: 'base' | 'adhoc';
  onClick?: () => void;
}
export declare function RuleRow(props: RuleRowProps): JSX.Element;
