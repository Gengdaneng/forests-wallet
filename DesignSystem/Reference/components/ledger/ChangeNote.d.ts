/** A visible record of a rule change. Rules are agreed together, so changes are never silent (PRD §5.4). */
export interface ChangeNoteProps {
  /** Written for Forrest, e.g. "从 10 月 1 日起，跳绳从 5 元变成 3 元". */
  text: string;
  date?: string;
  size?: 'child' | 'parent';
}
export declare function ChangeNote(props: ChangeNoteProps): JSX.Element;
