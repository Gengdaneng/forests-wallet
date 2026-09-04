/** Single-line text input. Every field in this product is optional — mark it so. */
export interface TextFieldProps {
  label?: string;
  value?: string;
  onChange?: (v: string) => void;
  placeholder?: string;
  /** Shows the 可跳过 hint. Almost always true here. */
  optional?: boolean;
  maxLength?: number;
  size?: 'child' | 'parent';
}
export declare function TextField(props: TextFieldProps): JSX.Element;
