/** Settings switch (parent side only — Forrest's iPad has no controls at all). */
export interface ToggleProps {
  checked?: boolean;
  onChange?: (next: boolean) => void;
  label: string;
  hint?: string;
  disabled?: boolean;
}
export declare function Toggle(props: ToggleProps): JSX.Element;
