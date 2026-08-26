import React from 'react';
import { DeleteIcon } from 'lucide-react';

interface KeypadProps {
  onPress: (digit: string) => void;
  onDelete: () => void;
}

const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

export function Keypad({ onPress, onDelete }: KeypadProps) {
  return (
    <div className="grid grid-cols-3 gap-2.5">
      {keys.map((key) =>
      <KeypadKey key={key} onClick={() => onPress(key)}>
          {key}
        </KeypadKey>
      )}
      <span />
      <KeypadKey onClick={() => onPress('0')}>0</KeypadKey>
      <KeypadKey onClick={onDelete} label="Delete">
        <DeleteIcon className="mx-auto h-7 w-7" strokeWidth={2.4} />
      </KeypadKey>
    </div>);

}

function KeypadKey({
  children,
  onClick,
  label




}: {children: React.ReactNode;onClick: () => void;label?: string;}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={label}
      className="h-16 rounded-btn bg-surface text-[28px] font-extrabold text-ink transition-[transform,background-color] duration-150 ease-swift active:scale-[0.97] active:bg-line">
      
      {children}
    </button>);

}