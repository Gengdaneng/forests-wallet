/**
 * Forrest's iPad navigation in regular landscape width. In compact/split width the
 * product switches to TabBar + single column rather than shrinking this (PRD §11).
 */
export interface SidebarItem { id: string; label: string; icon: string }
export interface SidebarProps {
  items: SidebarItem[];
  active?: string;
  onSelect?: (id: string) => void;
  /** Wordmark text — the source repo ships no logo file, so the name is set in type. */
  brand?: string;
  footer?: React.ReactNode;
}
export declare function Sidebar(props: SidebarProps): JSX.Element;
