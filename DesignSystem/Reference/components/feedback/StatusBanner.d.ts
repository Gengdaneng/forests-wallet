/**
 * Trust state. The ledger says out loud when it might be stale, and confirmations say
 * 已记录 — never 已转账 (PRD §2, §9.1).
 */
export interface StatusBannerProps {
  /** offline · failed · online · norealmoney */
  kind?: 'offline' | 'failed' | 'online' | 'norealmoney';
  /** Overrides the built-in copy. */
  text?: string;
  size?: 'child' | 'parent';
  style?: React.CSSProperties;
}
export declare function StatusBanner(props: StatusBannerProps): JSX.Element;
