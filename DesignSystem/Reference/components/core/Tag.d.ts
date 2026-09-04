/** Spend-category chip. Exports `CATEGORIES`, the 6 fixed MVP categories with their emoji glyphs. */
export interface TagProps {
  /** One of: food | toy | game | book | gift | other */
  category?: 'food' | 'toy' | 'game' | 'book' | 'gift' | 'other';
  /** Overrides the category label. */
  label?: string;
  emoji?: string;
  selected?: boolean;
  /** Present = the chip is a control and gets a 48/54px target. */
  onClick?: () => void;
  size?: 'child' | 'parent';
}
export declare function Tag(props: TagProps): JSX.Element;
export declare const CATEGORIES: { id: string; emoji: string; label: string }[];
