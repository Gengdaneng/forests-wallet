/** Bottom navigation: Dad's iPhone, and Forrest's iPad in compact/split width. Icons always carry labels. */
export interface TabBarProps {
  items: { id: string; label: string; icon: string }[];
  active?: string;
  onSelect?: (id: string) => void;
  /** Item id to raise as the honey entry-point action (the 记一笔 tab). */
  center?: string;
}
export declare function TabBar(props: TabBarProps): JSX.Element;
