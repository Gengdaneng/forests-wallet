/** The 6 fixed spend categories as selectable chips. Optional; skipping falls to 其他 (PRD §6.2). */
export interface CategoryPickerProps {
  value?: 'food' | 'toy' | 'game' | 'book' | 'gift' | 'other';
  onChange?: (v?: string) => void;
  size?: 'child' | 'parent';
  label?: string;
}
export declare function CategoryPicker(props: CategoryPickerProps): JSX.Element;
