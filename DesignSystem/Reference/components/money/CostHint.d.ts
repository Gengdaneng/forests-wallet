/** The visible-cost line shown after a spend: the whole of the savings lesson (PRD §8.1). */
export interface CostHintProps {
  /** The spend amount in cents. */
  cents: number;
  /** Current goal name; omitted reads as "你的目标". */
  goalTitle?: string;
  style?: React.CSSProperties;
}
export declare function CostHint(props: CostHintProps): JSX.Element;
