/** Empty ledger / empty wish list. Explains what will appear, and never suggests anything is wrong. */
export interface EmptyStateProps {
  /** Lucide name. Default "notebook-pen". */
  icon?: string;
  title: string;
  body?: string;
  size?: 'child' | 'parent';
}
export declare function EmptyState(props: EmptyStateProps): JSX.Element;
